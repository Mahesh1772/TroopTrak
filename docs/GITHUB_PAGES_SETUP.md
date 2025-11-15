# 🔧 GitHub Pages Setup Guide

## Issue: Seeing "Orbital Flutter App" Instead of Documentation

If you're seeing "Orbital Flutter App" on your GitHub Pages, it means GitHub Pages is reading from the wrong location or there's a configuration issue.

## ✅ Solution Steps

### Step 1: Verify Repository Settings

1. Go to your GitHub repository
2. Click **Settings** (top menu)
3. Scroll to **Pages** (left sidebar)
4. Check the configuration:
   - **Source:** Should be set to a branch (usually `main` or `gh-pages`)
   - **Branch:** Select `main` (or your default branch)
   - **Folder:** Select `/docs`
   - Click **Save**

### Step 2: Verify File Structure

Your repository should have this structure:

```
your-repo/
├── docs/
│   ├── _config.yml
│   ├── index.md          ← This is the main page
│   ├── USER_GUIDE.md
│   ├── DEVELOPER_GUIDE.md
│   └── ARCHITECTURE.md
└── (other files)
```

### Step 3: Ensure Files Are Committed

Make sure all files in the `docs/` folder are committed and pushed:

```bash
git add docs/
git commit -m "docs: add TroopTrak documentation"
git push origin main
```

### Step 4: Wait for GitHub Pages Build

After saving settings:
- GitHub will build your site (takes 1-5 minutes)
- Check the **Actions** tab to see build progress
- Look for a green checkmark ✓ when done

### Step 5: Check the URL

Your documentation should be at:
```
https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/
```

**Note:** If this is your user site (username.github.io), it should be:
```
https://YOUR_USERNAME.github.io/
```

## 🔍 Troubleshooting

### Issue 1: Still seeing wrong content

**Solution:** Clear browser cache or try incognito mode.

### Issue 2: Getting 404 error

**Possible causes:**
- Files not in `/docs` folder
- Wrong branch selected
- Build failed (check Actions tab)

**Solution:**
1. Verify files are in `docs/` folder
2. Check GitHub Actions for build errors
3. Try selecting a different branch/folder

### Issue 3: Jekyll build errors

If you see build errors in Actions:

1. Check `_config.yml` syntax (must be valid YAML)
2. Remove any problematic plugins
3. Ensure front matter is correct in `.md` files

### Issue 4: Only markdown showing (not rendered)

**Solution:**
- Ensure `_config.yml` exists
- Check that theme is set: `theme: jekyll-theme-cayman`
- Verify no `.nojekyll` file in docs folder

## 🔄 Alternative: Manual Setup

If Jekyll themes don't work, use plain HTML:

1. Rename `index.md` to `index.html`
2. Convert markdown to HTML (use online tool)
3. Remove `_config.yml` or simplify it

But first, try the Jekyll approach - it should work now with the fixes applied!

## ✅ What Should Work Now

After pushing the updated files:

1. ✅ `index.md` has Jekyll front matter
2. ✅ All guides have front matter
3. ✅ `.nojekyll` file removed
4. ✅ `_config.yml` configured properly
5. ✅ Links use Jekyll permalinks

Your site should now show:
- **Title:** TroopTrak Documentation
- **Content:** Full documentation homepage
- **Navigation:** Links to all guides

## 📝 Quick Verification Checklist

- [ ] Files are in `docs/` folder
- [ ] `_config.yml` exists
- [ ] `index.md` exists and has front matter
- [ ] GitHub Pages is set to `/docs` folder
- [ ] All changes are pushed to GitHub
- [ ] Build completed successfully (check Actions)
- [ ] Clear browser cache and reload

## 🚀 After Fixing

Once it's working, you should see:
- Professional-looking documentation site
- Navigation between pages
- All three guides accessible
- Proper formatting and styling

---

**Still having issues?** 

1. Check the GitHub Actions tab for build errors
2. Verify the repository name and settings
3. Make sure you're accessing the correct URL
4. Try creating a new branch and setting that as the source

