# nx-example

This monorepo utilizes Yarn as the package manager and Nx for monorepo
management. It houses multiple packages used for demonstration purposes.

Please note that newer versions of Yarn should not be installed globally as they
won't work to create the necessary package `node_modules` symlinks between
dependencies. Instead, it's necessary to enable Corepack. You can enable
Corepack by running the following command:

```bash
corepack enable
```

For more information, refer to the
[Yarn documentation](https://yarnpkg.com/getting-started/install).

Install monorepo build system.

```bash
npm install --global nx
```

Install and build all packages.

```bash
yarn install
nx run-many -t build --all
```

## Third-Party Documentation

[NX Package Based Repo](https://nx.dev/getting-started/tutorials/package-based-repo-tutorial)
