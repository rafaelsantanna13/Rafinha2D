const fs = require('node:fs');
if (fs.existsSync('node_modules')) fs.writeFileSync('node_modules/.gdignore', '');
