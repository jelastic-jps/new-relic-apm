import com.hivext.api.environment.Environment;

var APPID = getParam("TARGET_APPID"),
    SESSION = getParam("session"),
    oEnvService,
    envInfoResponse,
    oActions,
    envEngine,
    nodes;

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

oEnvService = hivext.local.exp.wrapRequest(new Environment(APPID, SESSION));
envInfoResponse = oEnvService.getEnvInfo();

if (!envInfoResponse.isOK()) {
    return envInfoResponse;
}

envEngine = toNative(envInfoResponse).env.engine.type;

return {
    result: 0,
    onAfterReturn: {
        call : oActions["${this.action}"][envEngine]
    }
};