const { spawn } = require('node:child_process');
const { mkdirSync, createWriteStream } = require('node:fs');
const { join } = require('node:path');

const logDir = join(process.cwd(), 'logs');
mkdirSync(logDir, { recursive: true });
const logPath = join(logDir, 'agent-nba.jsonl');
const logStream = createWriteStream(logPath, { flags: 'a' });

const args = [
  'apex', 'run',
  '--file', 'bootstrap/apex-templates/AgentRecommendationDemo.apex',
  '--json', '--quiet'
];

const child = spawn('sf', args, { stdio: ['ignore', 'pipe', 'pipe'] });

child.stdout.on('data', (chunk) => {
  process.stdout.write(chunk);
  logStream.write(chunk);
});
child.stderr.on('data', (chunk) => {
  process.stderr.write(chunk);
  logStream.write(chunk);
});
child.on('error', (error) => {
  logStream.end();
  console.error('Failed to start sf apex run:', error.message);
  process.exit(1);
});
child.on('close', (code) => {
  logStream.end();
  if (code !== 0) {
    console.error(`sf apex run exited with code ${code}`);
    process.exit(code);
  }
});
