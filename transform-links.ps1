# PowerShell script to transform HTML links to styled buttons
$content = (Get-Content ".github\scripts\sample.html") -join "`n"

# Replace all occurrences of the link pattern
$content = $content -replace 'div style="margin-top:6px; white-space:nowrap;">', 'div style="margin-top:6px;"><div style="display:inline-flex; gap:8px; flex-wrap:wrap;">'

# Replace View doc links
$content = $content -replace '<a href="([^"]+)" style="font-size:13px; color:#2563eb; text-decoration:none;">View doc</a>', '<a href="$1" style="display:inline-flex; align-items:center; background:linear-gradient(135deg, #3b82f6, #1d4ed8); color:#ffffff; text-decoration:none; font-size:13px; font-weight:500; padding:6px 12px; border-radius:6px; border:none; transition:all 0.2s;">📄 View doc</a>'

# Remove the separator
$content = $content -replace '\s*<span style="color:#9ca3af;"> · </span>\s*', ' '

# Replace View PR links  
$content = $content -replace '<a href="([^"]+)" style="font-size:13px; color:#2563eb; text-decoration:none;">View PR</a>', '<a href="$1" style="display:inline-flex; align-items:center; background:linear-gradient(135deg, #6b7280, #4b5563); color:#ffffff; text-decoration:none; font-size:13px; font-weight:500; padding:6px 12px; border-radius:6px; border:none; transition:all 0.2s;">🔗 View PR</a>'

# Add closing div for button container
$content = $content -replace '(🔗 View PR</a>)\s*</div>', '$1</div></div>'

# Write the transformed content back
$content | Out-File -FilePath ".github\scripts\sample.html" -Encoding UTF8