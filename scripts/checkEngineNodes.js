var APPID = getParam("TARGET_APPID"),
    SESSION = getParam("session"),
    oEnvService,
    envInfoResponse,
    oActions,
    envEngine,
    nodes,
    i;

oActions = {
    "install": {
        "java": "installJavaAgent",
        "php": "installPhpAgent"
    },
    "uninstall": {
        "java": "uninstallJavaAgent",
        "php": "uninstallPhpAgent"
    },
    "update": {
        "java": "updateJavaAgent",
        "php": "updatePhpAgent"
    }
};

oEnvService = jelastic.environment.control.GetEnvInfo(APPID, SESSION);

if (!oEnvService || oEnvService.result != 0) {
    return oEnvService;
}

if (oEnvService.env.engine) {
    envEngine = oEnvService.env.engine.type;
} else {
    if (oEnvService.nodes) {
        for (i = 0; oEnvService.nodes[i]; i += 1) {
            if (oEnvService.nodes[i].nodeGroup =='cp' && oEnvService.nodes[i].type == 'DOCKERIZED') {
                envEngine = oEnvService.nodes[i].engineType;
                break;
            }
        }
    }
}

return {
    result: 0,
    onAfterReturn: {
        call : oActions["${this.action}"][envEngine]
    }
};
