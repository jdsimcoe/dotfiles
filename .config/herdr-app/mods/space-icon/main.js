// Pick a space's icon: the project's SVGs, likeliest first (icon, logo, symbol,
// the space's name; shallow before deep), with previews. Type to filter, ↑/↓ and
// Enter to pick, Esc to leave. Opened by my-spaces with props { project, root,
// on, name, repo }; the pick goes in shared "space.icons" by project: a path from
// root, false for the letter, none for automatic.

import { View, div, image } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { exec, theme, settings, props, closeOverlay, shared, setShared } from "herdr";
import * as fs from "fs/promises";

// Previews load only from ~/.config/herdr-app: copied here, named by contents.
const PREVIEW_DIR = "mods/space-icon/.previews";
const SHOWN = 80;
const hash = (text) => {
  let h = 0x811c9dc5;
  for (let i = 0; i < text.length; i++) h = Math.imul(h ^ text.charCodeAt(i), 0x01000193);
  return (h >>> 0).toString(16);
};
const LIKELY = /(^|[\/._-])(icon|logo|favicon|symbol|mark|brand|avatar)([._-]|$)/i;
const UNLIKELY = /(^|\/)(node_modules|__generated__|test|tests|__tests__|fixtures|stories|vendor|dist|build)\//i;

// Higher is likelier: a name that says what it is, the space's own name, not deep.
export function score(path, name) {
  const file = path.split("/").pop().toLowerCase();
  const words = name.toLowerCase().split(/[^a-z0-9]+/).filter((w) => w.length > 2);
  let s = -path.split("/").length;
  if (LIKELY.test(file)) s += 6;
  if (words.some((w) => file.includes(w))) s += 8;
  if (/(^|[._-])(dark|black)([._-]|$)/.test(file) && !settings().dark) s += 1;
  if (/(^|[._-])(light|white)([._-]|$)/.test(file) && settings().dark) s += 1;
  if (UNLIKELY.test(path)) s -= 10;
  return s;
}

export default class SpaceIcon extends View {
  init(_props, cx) {
    const p = this.p = { project: null, root: null, on: null, name: "this space", repo: false, ...(props() ?? {}) };
    this.files = null; // every SVG under root, likeliest first
    this.previews = {}; // path -> its copy under PREVIEW_DIR, null: unreadable
    this.loading = new Set();
    this.filter = "";
    this.at = 0;
    this.handle = cx.focus_handle();
    this.input = InputState.new({ placeholder: `Search ${p.name}'s SVGs…` });
    this.input.on("change", (_e, cx) => { this.filter = this.input.value(); this.at = 0; this.preview(cx); cx.notify(); });
    this.input.on("submit", () => this.pick(this.rows()[this.at]));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    cx.spawn(async (cx) => {
      // Tracked and new-but-not-ignored files in a repo; in a plain folder, all but
      // node_modules and hidden folders, not too deep.
      if (!p.root) { this.files = []; return cx.notify(); }
      const list = p.repo
        ? ["git", ["ls-files", "--cached", "--others", "--exclude-standard", "--", "*.svg"]]
        : ["find", [".", "(", "-name", "node_modules", "-o", "-name", ".?*", ")", "-prune", "-o", "-maxdepth", "9", "-name", "*.svg", "-print"]];
      try {
        const r = await exec(list[0], list[1], { cwd: p.root, on: p.on });
        const paths = [...new Set(r.stdout.split("\n").map((l) => l.trim().replace(/^\.\//, "")).filter(Boolean))];
        this.files = paths.map((path) => ({ path, s: score(path, p.name) })).sort((a, b) => b.s - a.s || a.path.localeCompare(b.path)).map((f) => f.path);
      } catch {
        this.files = [];
      }
      this.home = (await exec("sh", ["-c", 'printf %s "$HOME"'])).stdout;
      this.preview(cx);
      cx.notify();
    });
  }

  close() {
    closeOverlay(this.p.overlay);
  }

  // Automatic and the letter, then the matches (every word somewhere in the path).
  rows() {
    const words = this.filter.toLowerCase().split(/\s+/).filter(Boolean);
    const hits = (this.files ?? []).filter((f) => words.every((w) => f.toLowerCase().includes(w))).slice(0, SHOWN);
    const fixed = words.length ? [] : [{ kind: "auto" }, { kind: "letter" }];
    return [...fixed, ...hits.map((path) => ({ kind: "file", path }))];
  }

  pick(r) {
    if (!r) return;
    const { project } = this.p;
    const picks = { ...(shared("space.icons") ?? {}) };
    if (r.kind === "auto") delete picks[project];
    else picks[project] = r.kind === "letter" ? false : r.path;
    setShared("space.icons", picks);
    this.close();
  }

  // Copies the shown rows' SVGs here, a few at a time, so they can be drawn.
  preview(cx) {
    if (!this.home) return;
    const { root, on } = this.p;
    const todo = this.rows().filter((r) => r.kind === "file" && !(r.path in this.previews) && !this.loading.has(r.path)).map((r) => r.path);
    if (!todo.length) return;
    todo.forEach((path) => this.loading.add(path));
    cx.spawn(async (cx) => {
      for (const path of todo) {
        try {
          const text = on ? (await exec("cat", [path], { cwd: root, on })).stdout : await fs.readFile(`${root}/${path}`, "utf8");
          if (!/<svg[\s>]/i.test(text)) throw new Error("not an svg");
          const copy = `${PREVIEW_DIR}/${hash(text)}.svg`;
          const file = `${this.home}/.config/herdr-app/${copy}`;
          if (!(await fs.exists(file))) {
            await fs.mkdir(`${this.home}/.config/herdr-app/${PREVIEW_DIR}`, { recursive: true });
            await fs.writeFile(file, text);
          }
          this.previews[path] = copy;
        } catch {
          this.previews[path] = null;
        }
        this.loading.delete(path);
      }
      cx.notify();
    });
  }

  thumb(t, r) {
    const edge = settings().dark ? "#ffffff24" : "#0000001f";
    const box = div().relative().size(22).flex_none().rounded(6).overflow_hidden();
    if (r.kind === "auto") return box.bg(t.raised).flex().items_center().justify_center().text_size(11).text_color(t.dim).child("A");
    if (r.kind === "letter") return box.bg("#22a99a").flex().items_center().justify_center().text_size(12).font_bold().text_color("#ffffff").child([...this.p.name][0]?.toUpperCase() ?? "?");
    const copy = this.previews[r.path];
    return box
      .when(Boolean(copy), (el) => el.child(image(copy).size_full().rounded(6)))
      .when(!copy, (el) => el.bg(t.raised))
      .child(div().absolute().inset_0().rounded(6).border(1).border_color(edge));
  }

  row(t, r, i, current) {
    const on = i === this.at;
    const picked = r.kind === "auto" ? current === undefined : r.kind === "letter" ? current === false : current === r.path;
    const dir = r.kind === "file" ? r.path.split("/").slice(0, -1).join("/") : "";
    const label = r.kind === "auto" ? "Automatic" : r.kind === "letter" ? "Letter" : r.path.split("/").pop();
    const note = r.kind === "auto" ? "an icon.svg, logo.svg or favicon.svg in the usual places" : r.kind === "letter" ? "no icon" : dir;
    return h_flex()
      .id(`icon-${i}`)
      .h(36)
      .flex_none()
      .px(10)
      .gap(10)
      .items_center()
      .rounded(7)
      .cursor_pointer()
      .when(on, (el) => el.bg(t.hover))
      .hover((s) => s.bg(t.hover))
      .on_click(() => this.pick(r))
      .child(this.thumb(t, r))
      .child(div().flex_none().max_w(200).truncate().text_color(t.foreground).child(label))
      .child(div().flex_1().min_w(0).truncate().text_size(11.5).text_color(t.dim).child(note))
      .when(picked, (el) => el.child(div().flex_none().text_size(11.5).text_color(t.accent).child("current")));
  }

  render() {
    const t = theme();
    const rows = this.rows();
    this.at = Math.max(0, Math.min(this.at, rows.length - 1));
    const current = (shared("space.icons") ?? {})[this.p.project];
    const total = this.files?.length ?? 0;
    return v_flex()
      .id("space-icon")
      .track_focus(this.handle)
      .size_full()
      .min_h(0)
      .p(14)
      .gap(10)
      .bg(t.popover)
      .text_size(13)
      .on_key_down((e, cx) => {
        if (e.key === "escape") return this.close();
        if (e.key === "down") this.at = (this.at + 1) % rows.length;
        else if (e.key === "up") this.at = (this.at + rows.length - 1) % rows.length;
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(h_flex().justify_between().items_center().px(4)
        .child(div().font_semibold().text_color(t.foreground).child(`Icon for ${this.p.name}`))
        .child(div().text_size(11.5).text_color(t.dim).child(this.files ? `${total} SVG${total === 1 ? "" : "s"}` : "Looking…")))
      .child(h_flex().h(34).px(10).rounded(7).border(1).border_color(t.input).items_center()
        .child(Input.new(this.input).flex_1().h_full().text_size(12.8).text_color(t.foreground)))
      .child(v_flex().id("icon-list").flex_1().min_h(0).gap(1).overflow_y_scrollbar()
        .children(rows.map((r, i) => this.row(t, r, i, current)))
        .when(Boolean(this.files) && rows.every((r) => r.kind !== "file"), (el) => el.child(
          div().px(10).py(8).text_size(12).text_color(t.dim).child(this.filter ? "No SVGs match." : "No SVGs here."))));
  }
}
