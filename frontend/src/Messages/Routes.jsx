module.exports = {
    childRoutes: [
        {
            path: "messages",
            indexRoute: {
                onEnter: (nextState, replace) => replace("/messages/history"),
            },
            childRoutes: [
                {
                    path: "images",
                    component: require("./ImageList").default,
                },
                {
                    path: "images/:image_id",
                    component: require("./ImageEdit").default,
                },
                {
                    path: "history",
                    component: require("./MessageList").default
                },
                {
                    path: "new",
                    component: require("./MessageAdd").default
                },
                {
                    path: "templates",
                    component: require("./TemplateList").default,
                },
                {
                    path: "templates/new",
                    component: require("./TemplateAdd").default,
                },
                {
                    path: "templates/:id",
                    component: require("./TemplateEdit").default,
                },
                {
                    path: ":id",
                    component: require("./MessageShow").default
                },
            ]
        },
    ]
};
