seajs.config({
	plugins: ["text"],
	alias: {
		"template": "lib/template.min",
		"aJazz": "lib/aJazz",
		"plugins": "lib/plugins"
	},
	preload: ["aJazz", "template", "plugins"]
});