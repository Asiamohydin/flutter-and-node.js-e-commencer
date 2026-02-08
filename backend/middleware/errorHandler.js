module.exports = (err, req, res, next) => {
  console.error('--- API ERROR ---');
  console.error(err);
  console.error('------------------');
  if (res.headersSent) return next(err);
  res.status(err.status || 500).json({ success: false, message: err.message || 'Server error' });
};
