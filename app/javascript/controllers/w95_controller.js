import { Controller } from "@hotwired/stimulus"

// Windows 95 property-sheet tabs and list-view selection, used by the ALTAMA.EXE Bot Manager window and the
// Extra Life event window. Works without JavaScript too: every panel is rendered, the first is shown by default.
export default class extends Controller {
  static targets = ["tab", "panel", "row", "detail", "group", "groupLabel", "eventField", "costField"]
  static values = { tab: String, selected: String, storageKey: String }

  connect() {
    const tab = this.tabValue || this.load("tab") || (this.hasTabTarget ? this.tabTargets[0].dataset.tab : null)
    if (tab) this.showTab(tab)
    const selected = this.selectedValue || this.load("selected")
    if (selected) this.showDetail(selected, false)
    this.element.querySelectorAll("select[data-mode-select]").forEach((s) => this.applyMode(s))
  }

  selectTab(event) {
    event.preventDefault()
    this.showTab(event.currentTarget.dataset.tab)
  }

  showTab(name) {
    if (!this.panelTargets.some((p) => p.dataset.tab === name)) return
    this.tabTargets.forEach((t) => {
      const active = t.dataset.tab === name
      t.classList.toggle("active", active)
      t.setAttribute("aria-selected", active ? "true" : "false")
    })
    this.panelTargets.forEach((p) => { p.hidden = p.dataset.tab !== name })
    this.save("tab", name)
  }

  selectRow(event) {
    if (event.target.closest("a, button, input, form")) return
    this.showDetail(event.currentTarget.dataset.id, true)
  }

  showNew(event) {
    event.preventDefault()
    this.showDetail(event.currentTarget.dataset.id || "new", true)
  }

  showDetail(id, scroll) {
    let found = false
    this.detailTargets.forEach((d) => {
      const match = d.dataset.id === id
      d.hidden = !match
      if (match) found = true
    })
    if (!found) return
    this.rowTargets.forEach((r) => r.classList.toggle("selected", r.dataset.id === id))
    const row = this.rowTargets.find((r) => r.dataset.id === id)
    if (row) {
      const group = row.closest("[data-w95-target~='group']")
      if (group && group.hidden) this.setGroup(group, true)
      if (scroll) row.scrollIntoView({ block: "nearest" })
    }
    this.save("selected", id)
  }

  toggleGroup(event) {
    event.preventDefault()
    const group = this.groupTargets.find((g) => g.dataset.group === event.currentTarget.dataset.group)
    if (group) this.setGroup(group, group.hidden)
  }

  setGroup(group, open) {
    group.hidden = !open
    this.groupLabelTargets
      .filter((l) => l.dataset.group === group.dataset.group)
      .forEach((l) => { l.textContent = open ? "▾" : "▸" })
  }

  modeChanged(event) {
    this.applyMode(event.currentTarget)
  }

  // Extra Life + Tiltify giveaways need an event and are free; other modes have no event.
  applyMode(select) {
    const form = select.closest("form")
    if (!form) return
    const eventMode = select.value === "extra-life-tiltify"
    form.querySelectorAll("[data-w95-target~='eventField']").forEach((el) => { el.hidden = !eventMode })
    form.querySelectorAll("[data-w95-target~='costField']").forEach((el) => {
      el.hidden = eventMode
      const input = el.querySelector("input")
      if (input && eventMode) input.value = 0
    })
    if (!eventMode) {
      const eventSelect = form.querySelector("select[name$='[extra_life_event_id]']")
      if (eventSelect) eventSelect.value = ""
    }
  }

  load(key) {
    if (!this.storageKeyValue) return null
    try { return window.sessionStorage.getItem(`${this.storageKeyValue}.${key}`) } catch (_) { return null }
  }

  save(key, value) {
    if (!this.storageKeyValue) return
    try { window.sessionStorage.setItem(`${this.storageKeyValue}.${key}`, value) } catch (_) { /* storage unavailable */ }
  }
}
