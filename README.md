# Example: Lighthouse CI Server with Cloud Run, Litestream, Cloudflare R2, and GitHub Actions

## Build Locally

1. Create a Cloudflare R2 bucket, and obtain the endpoint, bucket name, access key, and secret access key.

2. Rename the `.env.example` file to `.env` and substitute the values obtained in step 1 respectively.

3. Execute the following command to launch Docker locally.
```bash
docker image build -t lhci .
chmod +x ./docker-container-run.sh
./docker-container-run.sh
open http://localhost:9001/app/
```

## Deploy to Cloud Run

1. Execute the following command to build the image. Replace PROJECT_ID with your own.
```bash
gcloud builds submit --tag gcr.io/PROJECT_ID/lhci
```

2. Set the environment variables respectively and deploy to Cloud Run.
```bash
gcloud run deploy --image gcr.io/PROJECT_ID/lhci --set-env-vars R2_ENDPOINT=https://ACCOUNT_ID.r2.cloudflarestorage.com/,R2_BUCKET=xxxxx,R2_ACCESS_KEY_ID=yyyyy,R2_SECRET_ACCESS_KEY=zzzzz
```

## Create Lighthouse CI Project

1. Execute the following command to create LHCI project. Enter the URL of your LHCI server created in Cloud Run.
```bash
npm install -g @lhci/cli@0.13.x
lhci wizard
? Which wizard do you want to run? new-project
? What is the URL of your LHCI server? https://your-lhci-server.example.com/
? What would you like to name the project? My Favorite Project
? Where is the project's code hosted? https://github.com/yajihum/lhci
```
And note down the generated build token and admin token.
```bash
Created project My Favorite Project (XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX)!
Use build token XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX to connect.
Use admin token XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX to manage the project.
```

For more details, please refer to the following.
https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/getting-started.md#project-creation

## Create LHCI Configuration file to your app project.

1. Set the contents of the `lighthouserc.js` file as follows.   
Write the path you want to verify of your app project in the `url` field, and write the URL of Cloud Run in the `serverBaseUrl` field.
```js
module.exports = {
	ci: {
		collect: {
			startServerCommand: "npm start",
			url: ["http://localhost:3000"],
			numberOfRuns: 1,
			settings: {
				emulatedFormFactor: "desktop",
			},
		},
		upload: {
			target: "lhci",
			serverBaseUrl: "https://xxxxxxxxx.a.run.app",
		},
	},
};
```

## Set up GitHub Actions

1. Create `.github/workflows/ci.yml` to your app project root.

2. Set the contents of the ci.yml file as follows.
```yaml
name: CI
on: [push]
jobs:
  lhci:
    name: Lighthouse
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Use Node.js 18.x
        uses: actions/setup-node@v3
        with:
          node-version: 18.x
      - name: npm install, build
        run: |
          npm install
          npm run build
      - name: run Lighthouse CI
        run: |
          npm install -g @lhci/cli@0.13.x
          lhci autorun --config=./lighthouserc.js
        env:
          LHCI_TOKEN: ${{ secrets.LHCI_TOKEN }}
```

3. Create secrets in the Actions of your app project. Move to `https://github.com/username/your-app-project/settings/secrets/actions` and click `New repository secret` button. 

4. Enter `LHCI_TOKEN` in the Name field, and the build token you noted down earlier in the `Secret` field, then save it.

## Referense
https://github.com/GoogleChrome/lighthouse-ci