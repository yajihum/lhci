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
