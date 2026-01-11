const express = require('express');
const path = require('path');
const compression = require('compression');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 8080;

// Compression middleware
app.use(compression());

// Debug: Check if build directory exists
const webDir = path.join(__dirname, 'build/web');
console.log('📁 Looking for web files in:', webDir);
console.log('📁 Directory exists:', fs.existsSync(webDir));

if (fs.existsSync(webDir)) {
  console.log('📁 Files in build/web:', fs.readdirSync(webDir));
}

// Serve static files from the web directory
app.use(express.static(webDir, {
  maxAge: '1y',
  etag: true,
}));

// Handle all routes by serving index.html (for Flutter web routing)
app.get('*', (req, res) => {
  const indexPath = path.join(webDir, 'index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.status(500).send(`
      <h1>Build Error</h1>
      <p>index.html not found at: ${indexPath}</p>
      <p>Directory exists: ${fs.existsSync(webDir)}</p>
      <p>Files: ${fs.existsSync(webDir) ? fs.readdirSync(webDir).join(', ') : 'N/A'}</p>
    `);
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 TapTrade Admin Panel running on port ${PORT}`);
  console.log(`📱 Admin URL: http://localhost:${PORT}`);
});
