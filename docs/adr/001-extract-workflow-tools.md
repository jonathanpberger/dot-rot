# ADR-001: Extract Workflow Tools from dot-rot

**Date:** 2024-07-02
**Status:** Accepted
**Deciders:** JPB

## Context

The dot-rot repository has accumulated multiple concerns:
1. **System configuration** (dotfiles, shell config, VS Code settings)
2. **Development workflow tools** (yday-semantic, shadow-work, git-weekly)
3. **Personal productivity scripts** (calendar integration, project management)

This mixing of concerns creates several problems:
- Tools that could benefit others are buried in personal dotfiles
- Unclear boundaries between shareable utilities and personal configuration
- Difficult to maintain and version tools independently
- Hard for others to discover and use valuable workflow tools

## Decision

We will **extract workflow tools into separate, focused repositories** while keeping dot-rot focused solely on environment configuration.

### Repository Separation

**dot-rot (system configuration only):**
- Shell configuration and aliases
- VS Code settings and extensions
- macOS defaults and system preferences
- Homebrew package lists
- Setup and installation scripts
- Personal workflow orchestration (gday function)

**Standalone tool repositories:**
- `yday` - Git retrospective analysis tool
- `gday` - Calendar formatting utilities
- `shadow-work` - Multi-source project scanning

### Tool Characteristics

**Extractable tools have these properties:**
- Single, clear responsibility
- Useful to developers beyond JPB
- Can be versioned and maintained independently
- Can be installed via standard package managers (npm, brew)

**Tools that stay in dot-rot:**
- Personal workflow orchestration (gday calls external tools)
- System-specific configuration
- Highly personal productivity scripts

## Consequences

### Positive
- **Clear separation of concerns** - configuration vs. tools
- **Discoverability** - tools become findable via GitHub/npm
- **Sharing** - others can use and contribute to workflow tools
- **Maintenance** - independent versioning and development
- **Installation** - standard package management (`npm install -g yday`)
- **Focused dot-rot** - cleaner, more maintainable dotfile repository

### Negative
- **Initial extraction effort** - need to restructure existing tools
- **Dependency management** - dot-rot workflow depends on external packages
- **Multiple repositories** - more repos to maintain

### Risks & Mitigations
- **Risk:** Tools diverge from personal workflow needs
- **Mitigation:** Maintain primary development in personal workflow context
- **Risk:** Breaking changes in extracted tools affect daily workflow
- **Mitigation:** Pin to specific versions in dot-rot, careful semver

## Implementation

### Phase 1: Extract Core `yday`
- Create standalone `yday` npm package
- Consolidate yday-semantic, yday-smart, shadow-work functionality
- Single command with smart flags: `yday --today --shadow --alastair`
- Remove source tools from dot-rot/bin

### Phase 2: Update dot-rot Integration
- Update gday to call `yday` as external dependency
- Install yday via package manager in setup scripts
- Clean up dot-rot/bin directory

### Phase 3: Extract Additional Tools
- `project-discovery` from shadow-work concepts
- Calendar formatting utilities
- Other workflow tools as identified

### Success Criteria
- [x] `npm install -g yday` provides full retrospective functionality
- [ ] dot-rot/bin contains only system configuration tools  
- [ ] gday workflow continues to work seamlessly
- [x] Extracted tools have their own documentation and can be used independently

### Phase 2 Progress: gday Extraction (2025-01-21)
- [x] **gday-cli repository created** at `/Users/jpb/workspace/gday-cli`
- [x] **Modular architecture** with lib/ directory (banner.sh, config.sh, calendar.sh)
- [x] **Full command interface** (`gday`, `gday later`, `gday filtered`, `gday --help`)
- [x] **YAML configuration system** extracted from hardcoded Oh My Zsh plugin
- [x] **Cross-platform compatibility** tested (bash/zsh shell scripts)
- [x] **Distribution ready** (Homebrew formula + package.json for npm)
- [x] **Comprehensive README** with installation and usage documentation
- [x] **Version 3.10.0** with all features from original plugin maintained
- [ ] **GitHub repository** creation (pending)
- [ ] **dot-rot integration update** to use external gday (pending)

## Notes

This decision supports the "now.md" knowledge management workflow while making valuable development tools available to the broader community. The separation allows dot-rot to focus on its core mission: automating macOS development environment setup.
