---
description: Deploy new version following DevOps.click standards
---

# Deploy New Version Workflow

This workflow automates the deployment of new versions following DevOps.click standards.

## Steps:

1. **Check for modified files**
   ```bash
   git status --porcelain
   ```

2. **Identify modified modules**
   - Look for files with `DOCLI_MODULE_VERSION` in modified files
   - Check each modified module file for version updates needed

3. **Update main version file**
   ```bash
   # Read current version
   current_version=$(cat .devops/.version)
   
   # Increment version (you can choose: patch, minor, major)
   new_version="0.0.$(( ${current_version##*.} + 1 ))"
   
   # Update version file
   echo "$new_version" > .devops/.version
   ```

4. **Update module versions if modified**
   For each modified module file that contains `DOCLI_MODULE_VERSION`:
   ```bash
   # Check if module file was modified and has version
   if git diff --name-only HEAD~1 | grep -q "module_file"; then
     # Update module version (reset to 0.0.01 or increment as needed)
     sed -i 's/DOCLI_MODULE_VERSION="[^"]*"/DOCLI_MODULE_VERSION="0.0.01"/' module_file
   fi
   ```

5. **Update CHANGELOG.md**
   - Add new entry with current date
   - Follow the existing format
   - Place new version after the latest version
   - Include all changes made

6. **Stage files for commit**
   ```bash
   git add .devops/.version
   git add CHANGELOG.md
   # Add any modified module files
   git add .devops/functions/bash_basic_functions
   # Add other modified module files as needed
   ```

7. **Create commit**
   ```bash
   # Get current date
   current_date=$(date +%Y-%m-%d)
   
   # Create commit with proper format
   git commit -m "release/$new_version

## [$new_version] - $current_date
### Added
- [Describe new features added]

### Changed
- [Describe changes made]

### Fixed
- [Describe bugs fixed]

### Improved
- [Describe improvements made]"
   ```

8. **Verify commit**
   ```bash
   git log --oneline -1
   git show --name-only HEAD
   ```

9. **Optional: Create tag**
   ```bash
   git tag -a "v$new_version" -m "Release version $new_version"
   ```

10. **Optional: Push changes**
    ```bash
    git push origin main
    git push origin "v$new_version"
    ```

## Important Notes:

- **Always check** which files were modified before updating versions
- **Module version updates**: Only update `DOCLI_MODULE_VERSION` in files that were actually modified
- **CHANGELOG format**: Follow the existing pattern with proper markdown formatting
- **Commit message**: Use the exact format `release/X.Y.Z` with detailed changelog
- **Version increment**: Be consistent with your versioning strategy
- **Testing**: Always test changes before committing

## Module Version Update Rules:

1. **If a module file was modified** → Update its `DOCLI_MODULE_VERSION`
2. **If a module file was NOT modified** → Leave its version unchanged
3. **Common version resets**:
   - Major refactoring: Reset to `0.0.01`
   - Minor changes: Increment last number
   - Patches: Increment patch version

## Files to Check for Versions:

- `.devops/.version` (main version)
- `.devops/functions/bash_basic_functions`
- `.devops/functions/bash_terraform`
- `.devops/main/x_runtf`
- `.devops/main/x_runbuild`
- Any other files containing `DOCLI_MODULE_VERSION`

## Example Commands:

```bash
# Check modified files
git diff --name-only HEAD~1

# Find files with module versions
grep -r "DOCLI_MODULE_VERSION" .devops/ --include="*.sh"

# Update specific module version
sed -i 's/DOCLI_MODULE_VERSION="[^"]*"/DOCLI_MODULE_VERSION="0.0.02"/' .devops/functions/bash_basic_functions

# Verify changes
git diff --staged
```
