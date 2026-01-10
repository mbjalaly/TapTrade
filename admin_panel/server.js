const express = require('express');
const path = require('path');
const compression = require('compression');

const app = express();
const PORT = process.env.PORT || 8080;

// Compression middleware
app.use(compression());

// Serve static files from the web directory
app.use(express.static(path.join(__dirname, 'build/web'), {
  maxAge: '1y',
  etag: true,
}));

// Handle all routes by serving index.html (for Flutter web routing)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web', 'index.html'));
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 TapTrade Admin Panel running on port ${PORT}`);
  console.log(`📱 Admin URL: http://localhost:${PORT}`);
});

