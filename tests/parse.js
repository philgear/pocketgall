const fs = require('fs');
const data = fs.readFileSync('e2e-chart-err.json', 'utf16le');
try {
  const jsonStr = data.substring(data.indexOf('{'));
  const obj = JSON.parse(jsonStr);
  const error = obj.errors?.[0] || obj.suites[0]?.suites?.[0]?.specs?.[0]?.tests?.[0]?.results?.[0]?.error;
  console.log(error.message);
} catch (e) {
  console.error("Failed to parse JSON", e);
}
