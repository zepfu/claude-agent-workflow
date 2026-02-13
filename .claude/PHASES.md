# PHASES.md — Build Phases & Execution Plan

## Current Status

### Phase 1: Foundation — ACTIVE

**Built:**
- Agent definitions (23) in `global/agents/`
- Command definitions (4) in `global/commands/`
- Template directory structure with generic per-project files
- Worktree isolation added to template CLAUDE.md
- Cross-repo feedback section added to template CLAUDE.md
- Root files customized for this project (CLAUDE.md, SPEC.md, GUIDELINES.md, PHASES.md)
- Conversion docs reorganized into `conversion/v1.0.0/`
- Scripts: `package.sh`, `sync-global.sh`, `validate.sh`
- CI: GitHub Actions workflow (markdownlint, shellcheck, structure)
- `.gitignore`, `.markdownlint.json`, `VERSION`

**Gaps:**
- Initial commit and push
- GitHub Project board, labels, milestones, issues
- Validation pass (run scripts, fix any lint issues)

### Phase 2: Validation & Worktree Integration — NOT STARTED

### Phase 3: Polish & v1.0.0 Release — NOT STARTED

---

## Build Phases

### Phase 1: Foundation
**Deliverable:** Repository is clean, organized, has its first commit. Template directory is populated. CI runs on push. GitHub tracking is set up.

- [x] Create `.gitignore`
- [x] Delete Zone.Identifier artifacts
- [x] Create `VERSION` file (1.0.0)
- [x] Create `template/` directory structure
- [x] Add worktree isolation to `template/repo/CLAUDE.md`
- [x] Add cross-repo feedback to `template/repo/CLAUDE.md`
- [x] Customize root `CLAUDE.md` for this project
- [x] Customize `.claude/SPEC.md` for this project
- [x] Customize `.claude/GUIDELINES.md` for this project
- [x] Fill in `.claude/PHASES.md` (this file)
- [x] Reorganize `conversion/` into `conversion/v1.0.0/`
- [x] Create `scripts/package.sh`
- [x] Create `scripts/sync-global.sh`
- [x] Create `scripts/validate.sh`
- [x] Create `.markdownlint.json`
- [x] Create `.github/workflows/lint.yml`
- [ ] Initial commit and push
- [ ] Create GitHub Project board, labels, milestones
- [ ] Create initial GitHub Issues

### Phase 2: Validation & Worktree Integration
**Deliverable:** Template validated on real projects. Worktree pattern tested. Cross-repo feedback loop proven.

- [ ] Run `scripts/package.sh` and verify zip structure
- [ ] Test `/convert` on a fresh project using packaged zip
- [ ] Test `/convert` on an existing CTO-orchestrator project
- [ ] Validate worktree isolation in real parallel dispatch
- [ ] Validate cross-repo feedback format works in practice
- [ ] Incorporate feedback from test conversions
- [ ] Update template based on findings

### Phase 3: Polish & v1.0.0 Release
**Deliverable:** Polished v1.0.0 release with complete documentation.

- [ ] Final documentation pass (TECH-WRITER review)
- [ ] Packaging script tested end-to-end
- [ ] All linting green in CI
- [ ] Tag v1.0.0 release
- [ ] Generate release zip artifact
- [ ] Create GitHub Release with zip attached

---

## Phase Gate Checks

### Phase 1 → Phase 2

All must be true:
- [ ] Initial commit pushed to GitHub
- [ ] CI pipeline runs (even if some lint issues remain)
- [ ] Template directory has all required files
- [ ] Scripts are executable and pass shellcheck
- [ ] GitHub Project board configured with labels and milestones

### Phase 2 → Phase 3

All must be true:
- [ ] CI green on main (`gh run list --status failure` returns empty)
- [ ] At least one successful `/convert` on a fresh project
- [ ] At least one successful `/convert` on an existing project
- [ ] Worktree isolation validated in real dispatch
- [ ] Cross-repo feedback entry received from external project
- [ ] No Critical/High issues open

### Phase 3 → v1.0.0 Release

- [ ] CI green on main — all GitHub Actions passing
- [ ] All markdown files pass linting
- [ ] All shell scripts pass shellcheck
- [ ] `scripts/package.sh` produces valid zip
- [ ] Documentation reviewed by TECH-WRITER
- [ ] Operator approval for release
