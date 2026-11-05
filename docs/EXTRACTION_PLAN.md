# Tool Extraction Plan

## Overview
Extract development workflow tools from dot-rot into standalone, shareable npm packages while maintaining current workflow.

## Current State Analysis

### Existing Tools in dot-rot/bin:
- `yday-semantic` - Semantic commit analysis using git-standup
- `yday-smart` - Smart daily/weekly reporter (calls yday-semantic or alastair-review)  
- `shadow-work` - Identifies repos with commits but no GitHub project tracking
- `git-weekly` - Weekly git activity reports
- `alastair-review` - Weekly digest in Alastair Method format

### Current Workflow:
- **`gday`** = Morning orientation (calendar + todo + retrospective summary)
- **`yday`** = Quick retrospective check ("what was I working on?")
  - Needs Monday extension for weekend gap
  - `yday --today` is clumsy but acceptable

## Proposed Solution: Single `yday` Tool

### Command Interface
```bash
yday                    # yesterday (or last weekday on Monday)
yday --today           # today's commits  
yday --alastair        # calendar-style visual timeline
yday --days 3          # last 3 days
yday --last-weekday    # explicit last business day
yday --shadow          # shadow-work mode (find untracked repos)
```

### Flag Combinations
```bash
yday --days 7 --alastair        # week timeline view
yday --shadow --days 3          # untracked repos from last 3 days
yday --today --shadow           # today's work + project gaps
```

## Implementation Phases

### Phase 1: Extract Core `yday` Package
**Goal:** Create standalone `yday` npm package with current yday-semantic functionality

**Tasks:**
- [ ] Create new npm package structure
- [ ] Extract yday-semantic logic (semantic commit analysis)
- [ ] Add smart Monday behavior (last weekday logic)
- [ ] Implement flexible time period handling
- [ ] Add comprehensive CLI argument parsing
- [ ] Write tests and documentation
- [ ] Publish to npm as `@jpb/yday` or similar

**Current Features to Preserve:**
- git-standup integration
- Semantic commit categorization
- Table output format with repos/commits/summary
- Smart time period calculation

### Phase 2: Add Alastair Calendar Mode
**Goal:** Add `--alastair` flag for visual timeline view

**Tasks:**
- [ ] Implement calendar-style git activity visualization
- [ ] Time-based layout showing commits across days/weeks
- [ ] Visual indicators for different types of work
- [ ] Integration with existing semantic analysis

**Inspired by:** `alastair-review` format but as a mode within yday

### Phase 3: Integrate Shadow Work Analysis  
**Goal:** Add `--shadow` flag for project tracking gaps

**Tasks:**
- [ ] Integrate shadow-work logic into yday
- [ ] GitHub project integration via gh CLI
- [ ] Identify repos with commits but no project tracking
- [ ] Option to create tracking issues automatically

**Current shadow-work features to integrate:**
- Cross-reference commit activity with GitHub projects
- Automatic issue creation for untracked repos
- Dry-run mode for previewing changes

### Phase 4: Update Existing Workflow
**Goal:** Replace dot-rot tools with extracted package

**Tasks:**
- [ ] Update `gday` to call extracted `yday` package
- [ ] Remove old tools from dot-rot/bin
- [ ] Update aliases.zsh to point to npm-installed version
- [ ] Test entire morning workflow (gday → yday integration)

## Tool Architecture

### Core Modules
```
yday/
├── src/
│   ├── git-analysis.js     # git-standup integration & commit parsing
│   ├── semantic.js         # commit message categorization  
│   ├── timeline.js         # alastair calendar view
│   ├── shadow.js           # project tracking analysis
│   ├── time-periods.js     # smart date handling
│   └── cli.js              # argument parsing & main entry
├── package.json
├── README.md
└── bin/yday               # executable
```

### Integration Points
- **git-standup:** Core git commit collection
- **GitHub CLI:** Project tracking for shadow mode
- **Terminal output:** Rich table formatting and colors
- **Calendar integration:** Time period calculations

## Benefits

### For Personal Workflow
- Single command with multiple views of git activity
- Maintains current `yday` naming that feels right
- Consolidates scattered functionality
- Cleans up dot-rot repository

### For Sharing
- Standalone npm package others can use
- Clear single responsibility: "what have I been working on?"
- Composable flags for different use cases
- Standard package management

## Context: "now.md" Workflow

This extraction supports the existing "now.md" knowledge capture system:
- `gday` provides morning orientation with calendar + retrospective
- `yday` provides quick retrospective checks throughout the day
- Both integrate with foam-based daily note structure
- Maintains current daily routine while enabling tool sharing

## Success Criteria

### Phase 1 Complete When:
- [ ] `npm install -g @jpb/yday` works
- [ ] `yday` command provides same output as current yday-semantic
- [ ] Smart Monday behavior works (shows Friday's work)
- [ ] All time period flags work correctly

### Full Project Complete When:
- [ ] `gday` successfully calls extracted yday
- [ ] All legacy yday tools removed from dot-rot
- [ ] `yday --alastair` provides visual timeline
- [ ] `yday --shadow` identifies and optionally creates tracking issues
- [ ] Documentation exists for other developers to use the tool

## Future Considerations

### Additional Tools for Extraction
- `git-weekly` - Could become `yday --days 7 --alastair`
- `project-discovery` - Separate tool for comprehensive project scanning
- Calendar tools from `gday` - Potential separate package for daily note templates

### Integration Opportunities
- VS Code extension for yday integration
- GitHub Actions for automated project tracking
- Slack/Discord bots for team retrospectives
- Integration with other time tracking tools