// A Linear team's open issues for the sidebar, grouped by status, read through Kit
// (`kit exec fetch.js`): no API key, the person's own Linear connection.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, home, appHome, run, theme, props } from "herdr";

// Where Linear puts each kind of state: closest to done first, as the team's board reads.
const ORDER = { triage: 0, started: 1, unstarted: 2, backlog: 3 };
const PRIORITY = { 1: "Urgent", 2: "High", 3: "Medium", 4: "Low" };

function age(iso) {
  const m = Math.floor((Date.now() - Date.parse(iso)) / 60000);
  if (m < 60) return `${Math.max(m, 1)}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

// Linear's priority glyph: three rising bars, filled to the priority; urgent is a mark.
function priority(p, t) {
  if (p === 1) return div().w(14).h(14).flex_none().rounded(3).bg(t.blocked).text_color(t.background).text_size(10).font_semibold().flex().items_center().justify_center().child("!");
  if (!p) return div().w(14).flex_none().text_size(10).text_color(t.dim).child("---");
  const filled = { 2: 3, 3: 2, 4: 1 }[p];
  return h_flex().w(14).h(14).flex_none().gap(1.5).items_end().justify_center()
    .children([5, 8, 11].map((h, i) => div().w(2.5).h(h).rounded(1).bg(i < filled ? t.muted : t.border)));
}

// The status circle in the state's own color: hollow until started, then filled.
function state(g, t) {
  const started = g.type === "started";
  return div().w(10).h(10).flex_none().rounded_full().border(1.5).border_color(g.color ?? t.dim)
    .when(started, (el) => el.bg(g.color ?? t.dim));
}

// The right panel's lower half holds Linear and Vercel as one stack: each header switches it.
function switcher(on, t) {
  return h_flex().gap(12).items_center().children(["linear", "vercel"].map((id) => div().id(`switch-${id}`)
    .font_semibold().text_color(id === on ? t.foreground : t.dim)
    .when(id !== on, (el) => el.cursor_pointer().hover((s) => s.text_color(t.muted)).on_click(() => run("layout.select", { stack: "integrations", child: id })))
    .child(id === "linear" ? "Linear" : "Vercel")));
}

export default class Linear extends View {
  init(_props, cx) {
    this.team = props()?.team ?? "GROW";
    this.limit = props()?.limit ?? 50;
    const cached = JSON.parse(localStorage.getItem("issues") ?? "null");
    this.data = cached?.team === this.team ? cached : null;
    // Backlog is long and rarely the point: folded until opened.
    this.folded = new Set(JSON.parse(localStorage.getItem("folded") ?? '["backlog"]'));
    this.refresh(cx);
    cx.timer.every(5 * 60000, (cx) => this.refresh(cx));
  }

  refresh(cx) {
    if (this.loading) return;
    this.loading = true;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const r = await exec(`${home()}/.config/kit/bin/kit`, ["exec", `${appHome()}/mods/linear/fetch.js`, "--input", JSON.stringify({ team: this.team })]);
        const out = JSON.parse(r.stdout || "{}");
        if (out.status !== "ok") throw new Error(out.message ?? out.status ?? (r.stderr.trim() || "Kit didn't answer"));
        this.data = { ...out.output, fetched: Date.now() };
        this.error = null;
        localStorage.setItem("issues", JSON.stringify(this.data));
      } catch (e) {
        this.error = String(e?.message ?? e);
      } finally {
        this.loading = false;
        cx.notify();
      }
    });
  }

  fold(key, cx) {
    this.folded.has(key) ? this.folded.delete(key) : this.folded.add(key);
    localStorage.setItem("folded", JSON.stringify([...this.folded]));
    cx.notify();
  }

  // Starts Claude on the issue in a new tab of the current space.
  work(issue) {
    run("tab.new", {
      name: issue.id,
      argv: ["claude"],
      task: `Work on Linear issue ${issue.id}: ${issue.title}\n${issue.url}\nUse the git branch ${issue.branch}.`,
    });
  }

  row(issue, t) {
    const hovered = this.hovered === issue.id;
    return h_flex().id(`li-${issue.id}`).px(8).h(28).flex_none().rounded(8).items_center().gap(8)
      .cursor_pointer().hover((s) => s.bg(t.hover))
      .tooltip(`${issue.id} · ${issue.title}${PRIORITY[issue.priority] ? ` · ${PRIORITY[issue.priority]}` : ""}`)
      .on_hover((on, cx) => {
        if (on) this.hovered = issue.id;
        else if (this.hovered === issue.id) this.hovered = null;
        cx.notify();
      })
      .on_click(() => exec("open", [issue.url]))
      .child(priority(issue.priority, t))
      .child(div().flex_none().text_size(11).text_color(t.dim).child(issue.id))
      .child(div().flex_1().min_w(0).truncate().text_color(t.foreground).child(issue.title))
      .when(hovered, (el) => el.child(div().id(`li-work-${issue.id}`).flex_none().p(2).rounded(4).text_color(t.dim)
        .hover((s) => s.bg(t.raised).text_color(t.foreground))
        .tooltip("Start Claude on this issue")
        .on_click((_e, cx) => { cx.stop_propagation(); this.work(issue); })
        .child(svg("mods/workspace-chrome/terminal.svg").size(13))))
      .when(!hovered, (el) => el.child(div().flex_none().text_size(11).text_color(t.dim).child(age(issue.updated))));
  }

  render() {
    const t = theme();
    const groups = [...(this.data?.groups ?? [])]
      .filter((g) => g.issues.length)
      .sort((a, b) => (ORDER[a.type] ?? 9) - (ORDER[b.type] ?? 9) || b.position - a.position);
    const total = groups.reduce((n, g) => n + g.issues.length, 0);

    const header = (g) => {
      const open = !this.folded.has(g.type === "backlog" ? "backlog" : g.name);
      const full = g.issues.length >= this.limit ? `${this.limit}+` : String(g.issues.length);
      return h_flex().id(`lg-${g.name}`).px(8).pt(8).h(30).flex_none().gap(7).items_center()
        .text_size(11).font_medium().cursor_pointer()
        .on_click((_e, cx) => this.fold(g.type === "backlog" ? "backlog" : g.name, cx))
        .child(state(g, t))
        .child(div().truncate().text_color(t.muted).child(g.name))
        .child(div().text_color(t.dim).child(full))
        .child(div().flex_1())
        .child(svg(`mods/workspace-chrome/chevron-${open ? "down" : "right"}.svg`).size(11).flex_none().text_color(t.dim));
    };
    const rows = groups.flatMap((g) => [header(g), ...(this.folded.has(g.type === "backlog" ? "backlog" : g.name) ? [] : g.issues.map((i) => this.row(i, t)))]);
    const note = this.error ? `Couldn't reach Linear: ${this.error}` : !this.data ? "Loading issues…" : total === 0 ? `No open issues in ${this.team}` : null;

    return v_flex().id("li-root").size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background).border_1().border_color(t.border).text_color(t.foreground).text_size(13)
      .child(h_flex().h(42).flex_none().px(14).gap(8).items_center().border_b(1).border_color(t.border)
        .child(switcher("linear", t))
        .child(div().px(5).py(1).rounded(4).border_1().border_color(t.border).text_size(10).text_color(t.muted).max_w(160).truncate().child(this.team))
        .child(div().flex_1())
        .child(div().id("li-refresh").text_color(t.dim).hover((s) => s.text_color(t.foreground))
          .tooltip(this.loading ? "Refreshing…" : "Refresh")
          .on_click((_e, cx) => this.refresh(cx))
          .child(this.loading ? svg("mods/workspace-chrome/spinner.svg").size(13).spin(900) : svg("mods/linear/refresh.svg").size(13))))
      .when(Boolean(note), (el) => el.child(div().px(14).pt(10).text_size(12).text_color(this.error ? t.blocked : t.dim).child(note)))
      .child(v_flex().id("li-list").flex_1().min_h(0).p(6).overflow_y_scrollbar().children(rows));
  }
}
