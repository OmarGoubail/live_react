import * as esbuild from 'esbuild'


const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

const loader = {
  // Add ".js" to the array of extensions for JavaScript files
  '.js': 'jsx',
  '.ts': 'tsx',
}

// Client bundle
const clientOptions = {
  entryPoints: ['js/app.js'],
  bundle: true,
  target: 'es2017',
  outdir: '../priv/static/assets',
  logLevel: 'info',
  loader,
  external: ['*.css'],
}
if (deploy) {
  clientOptions.minify = true
}

// Server bundle
const serverOptions = {
  entryPoints: ['js/server.js'],
  platform: 'node',
  format: 'cjs',
  outdir: '../priv/react',
  bundle: true,
  logLevel: 'info',
  loader,
}

if (watch) {
  const clientContext = await esbuild.context({ ...clientOptions })
  await clientContext.watch()
  const serverContext = await esbuild.context({ ...serverOptions })
  await serverContext.watch()
} else {
  await esbuild.build(clientOptions)
  await esbuild.build(serverOptions)
  process.exit(0)
}