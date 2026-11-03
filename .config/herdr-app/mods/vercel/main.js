// Vercel deployments for the sidebar, through the logged-in `vercel` CLI. In a folder linked
// to a Vercel project: that project's. Anywhere else: your own commits' deployments in a team.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, readTextFile, spaces, panes, focused, run, theme, props } from "herdr";

const BUSY = new Set(["BUILDING", "INITIALIZING", "QUEUED"]);
const LABEL = { READY: "Ready", ERROR: "Error", BUILDING: "Building", INITIALIZING: "Initializing", QUEUED: "Queued", CANCELED: "Canceled" };
// A commit's state: its most urgent built deployment's.
const URGENT = ["ERROR", "BUILDING", "INITIALIZING", "QUEUED", "READY"];

// One row per commit. A monorepo push starts a deployment in every project connected to
// the repo and Vercel cancels the ones the change doesn't touch: count those, show the rest.
function byCommit(deployments) {
  const commits = new Map();
  for (const d of deployments) {
    const m = d.meta ?? {}, key = m.githubCommitSha ?? d.url;
    let c = commits.get(key);
    if (!c) commits.set(key, c = {
      key, created: d.createdAt, built: [], skipped: 0,
      message: (m.githubCommitMessage ?? "").split("\n")[0] || d.name, branch: m.githubCommitRef ?? null,
      commitUrl: m.githubCommitSha && m.githubOrg && m.githubRepo ? `https://github.com/${m.githubOrg}/${m.githubRepo}/commit/${m.githubCommitSha}` : null,
    });
    c.created = Math.max(c.created, d.createdAt);
    if (d.state === "CANCELED") c.skipped++;
    else c.built.push({ url: d.url, name: d.name, state: d.state, target: d.target });
  }
  return [...commits.values()].map((c) => ({
    ...c, state: URGENT.find((s) => c.built.some((b) => b.state === s)) ?? "CANCELED",
    production: c.built.some((b) => b.target === "production"),
  }));
}

function age(ms) {
  const m = Math.floor((Date.now() - ms) / 60000);
  if (m < 60) return `${Math.max(m, 1)}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

// Where the person is: the focused pane's folder, else the shown space's. This machine only.
function cwd() {
  const f = focused(), space = spaces().find((s) => s.active);
  if (space?.machine) return null;
  const pane = f?.pane ? panes().find((p) => p.pane === f.pane) : null;
  return pane?.cwd || f?.cwd || space?.folder || null;
}

// The right panel's lower half holds Linear and Vercel as one stack: each header switches it.
function switcher(on, t) {
  return h_flex().gap(12).items_center().children(["linear", "vercel"].map((id) => div().id(`switch-${id}`)
    .font_semibold().text_color(id === on ? t.foreground : t.dim)
    .when(id !== on, (el) => el.cursor_pointer().hover((s) => s.text_color(t.muted)).on_click(() => run("layout.select", { stack: "integrations", child: id })))
    .child(id === "linear" ? "Linear" : "Vercel")));
}

export default class Vercel extends View {
  init(_props, cx) {
    this.team = props()?.team ?? "vercel";
    this.deployments = JSON.parse(localStorage.getItem("commits") ?? "[]");
    this.login = localStorage.getItem("login");
    this.refresh(cx);
    // Every 20 s while something builds, else every minute.
    this.ticks = 0;
    cx.timer.every(20000, (cx) => {
      this.ticks++;
      if (this.deployments.some((d) => BUSY.has(d.state)) || this.ticks % 3 === 0) this.refresh(cx);
      else cx.notify();
    });
  }

  // The linked project's folder (.vercel/project.json here or at the repo's top), or null.
  async linked(dir) {
    if (!dir) return null;
    const top = await exec("git", ["rev-parse", "--show-toplevel"], { cwd: dir }).catch(() => null);
    for (const d of [dir, top?.code === 0 ? top.stdout.trim() : null].filter(Boolean)) {
      const text = await readTextFile(`${d}/.vercel/project.json`).catch(() => null);
      if (text) return { dir: d, project: JSON.parse(text).projectName ?? d.split("/").pop() };
    }
    return null;
  }

  refresh(cx) {
    if (this.loading) return;
    this.loading = true;
    const dir = cwd();
    cx.spawn(async (cx) => {
      try {
        const link = await this.linked(dir);
        let args, opts = {};
        if (link) {
          args = ["ls", "--json", "-n", "40"];
          opts = { cwd: link.dir };
        } else {
          if (!this.login) {
            const r = await exec("gh", ["api", "user", "-q", ".login"]).catch(() => null);
            this.login = r?.code === 0 ? r.stdout.trim() : null;
            if (this.login) localStorage.setItem("login", this.login);
          }
          args = ["ls", "--json", "-n", "100", "--scope", this.team, ...(this.login ? ["--meta", `githubCommitAuthorLogin=${this.login}`] : [])];
        }
        const r = await exec("vercel", args, opts);
        const out = JSON.parse(r.stdout || "{}");
        if (!out.deployments) throw new Error(out.message ?? (r.stderr.trim().split("\n").pop() || "No answer from vercel"));
        this.scope = out.contextName ?? this.team;
        this.title = link ? link.project : this.login ? "Your deployments" : "Deployments";
        this.deployments = byCommit(out.deployments).slice(0, 25);
        this.project = link?.project ?? null;
        this.error = null;
        localStorage.setItem("commits", JSON.stringify(this.deployments));
      } catch (e) {
        this.error = String(e?.message ?? e);
      } finally {
        this.loading = false;
        cx.notify();
      }
    });
  }

  dot(d, t) {
    const color = d.state === "READY" ? t.ansi2 : d.state === "ERROR" ? t.ansi1 : BUSY.has(d.state) ? t.working : t.dim;
    return div().w(8).h(8).flex_none().rounded_full().bg(color)
      .when(BUSY.has(d.state), (el) => el.loop("opacity", { from: 0.35, to: 1, period: 1100 }));
  }

  row(c, t) {
    const hovered = this.hovered === c.key, first = c.built[0];
    // What built: in a project, the branch says more; across a team, the projects.
    const names = [...new Set(c.built.map((b) => b.name))];
    const detail = this.project ? c.branch : names.length > 2 ? `${names[0]} +${names.length - 1}` : names.join(", ") || "nothing built";
    const tip = [
      `${LABEL[c.state] ?? c.state}${c.branch ? ` · ${c.branch}` : ""}`, c.message,
      ...c.built.map((b) => `${LABEL[b.state] ?? b.state} · ${b.name}${b.target === "production" ? " (production)" : ""}`),
      c.skipped ? `${c.skipped} other project${c.skipped === 1 ? "" : "s"} skipped: no changes for them` : null,
    ].filter(Boolean).join("\n");
    return h_flex().id(`vd-${c.key}`).px(8).h(28).flex_none().rounded(8).items_center().gap(8)
      .cursor_pointer().hover((s) => s.bg(t.hover))
      .tooltip(tip)
      .on_hover((on, cx) => {
        if (on) this.hovered = c.key;
        else if (this.hovered === c.key) this.hovered = null;
        cx.notify();
      })
      .on_click(() => { const url = first ? `https://${first.url}` : c.commitUrl; if (url) exec("open", [url]); })
      .child(this.dot(c, t))
      .child(h_flex().flex_1().min_w(0).gap(5).items_center()
        .child(div().flex_1().min_w(0).truncate().text_color(first ? t.foreground : t.muted).child(c.message))
        .when(Boolean(detail), (el) => el.child(div().flex_none().max_w(140).truncate().text_color(t.dim).child(`· ${detail}`))))
      .when(c.production, (el) => el.child(div().flex_none().px(4).rounded(3).border_1().border_color(t.border).text_size(9.5).text_color(t.muted).child("Prod")))
      .when(hovered && Boolean(first), (el) => el.child(div().id(`vd-logs-${c.key}`).flex_none().p(2).rounded(4).text_color(t.dim)
        .hover((s) => s.bg(t.raised).text_color(t.foreground))
        .tooltip(`Build logs for ${first.name} in a terminal`)
        .on_click((_e, cx) => {
          cx.stop_propagation();
          run("terminal.open", { argv: ["vercel", "inspect", "--logs", first.url, "--scope", this.scope ?? this.team], place: "tab", name: `logs ${first.name}` });
        })
        .child(svg("mods/workspace-chrome/terminal.svg").size(13))))
      .when(!(hovered && first), (el) => el.child(div().flex_none().text_size(11).text_color(t.dim).child(age(c.created))));
  }

  render(cx) {
    const t = theme();
    // A new place may be a different project: look again when the folder changes.
    const here = cwd();
    if (here !== this.where) { this.where = here; this.refresh(cx); }
    const note = this.error ? `Couldn't reach Vercel: ${this.error}` : !this.deployments.length ? (this.loading ? "Loading deployments…" : "No deployments yet") : null;
    return v_flex().id("vd-root").size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background).border_1().border_color(t.border).text_color(t.foreground).text_size(13)
      .child(h_flex().h(42).flex_none().px(14).gap(8).items_center().border_b(1).border_color(t.border)
        .child(switcher("vercel", t))
        .child(div().px(5).py(1).rounded(4).border_1().border_color(t.border).text_size(10).text_color(t.muted).max_w(160).truncate().child(this.title ?? this.team))
        .child(div().flex_1())
        .child(div().id("vd-refresh").text_color(t.dim).hover((s) => s.text_color(t.foreground))
          .tooltip(this.loading ? "Refreshing…" : "Refresh")
          .on_click((_e, cx) => this.refresh(cx))
          .child(this.loading ? svg("mods/workspace-chrome/spinner.svg").size(13).spin(900) : svg("mods/vercel/refresh.svg").size(13))))
      .when(Boolean(note), (el) => el.child(div().px(14).pt(10).text_size(12).text_color(this.error ? t.blocked : t.dim).child(note)))
      .child(v_flex().id("vd-list").flex_1().min_h(0).p(6).overflow_y_scrollbar().children(this.deployments.map((d) => this.row(d, t))));
  }
}
