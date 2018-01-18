global class FeatureManagementDEV {
    /**
     * Test various FM capabilities.
     **/
    global static List<String> runFmTestReport() {
        List<String> returnValues = new List<String>();

        returnValues.add('SymbolSearchEnabled-->' + Application.Features.SymbolSearchEnabled);
        returnValues.add('SymbolSearchPermitted-->' + Application.Features.SymbolSearchPermitted);
        
        System.debug('SymbolSearchEnabled-->' + FeatureManagement.checkPackageBooleanValue('SymbolSearchEnabled'));
        System.debug('SymbolSearchPermitted-->' + FeatureManagement.checkPackageBooleanValue('SymbolSearchPermitted'));

        Application.Features.SymbolSearchEnabled = true;
        returnValues.add('SymbolSearchEnabled (After Change1)-->' + Application.Features.SymbolSearchEnabled);
        System.debug('SymbolSearchEnabled (After Change1)-->' + FeatureManagement.checkPackageBooleanValue('SymbolSearchEnabled'));

        Application.Features.SymbolSearchEnabled = false;
        returnValues.add('SymbolSearchEnabled (After Change2)-->' + Application.Features.SymbolSearchEnabled);
        System.debug('SymbolSearchEnabled (After Change2)-->' + FeatureManagement.checkPackageBooleanValue('SymbolSearchEnabled'));

        return returnValues;
    }

    global static void toggleSymbolSearchEnabled() {
        Application.Features.SymbolSearchEnabled = (! Application.Features.SymbolSearchEnabled);
    }

    global static void toggleSymbolSearchPermitted() {
        Application.Features.SymbolSearchPermitted = (! Application.Features.SymbolSearchPermitted);
    }

    global static void setProtection(String permissionName) {
        // This will COMPILE, but it can not be EXECUTED outside of the context of a managed
        // package without causing a GACK. (-2003838583)
        FeatureManagement.changeProtection(permissionName, 'CustomPermission', 'Protected');
    }

    global static void removeProtection(String permissionName) {
        // This will COMPILE, but it can not be EXECUTED outside of the context of a managed
        // package without causing a GACK. (-2003838583)
        FeatureManagement.changeProtection(permissionName, 'CustomPermission', 'Unprotected');
    }

    global static String checkProtection(String permissionName) {
        if (Application.Permissions.DW_Symbol_Search) {
            return 'Running user HAS the DW_Symbol_Search perm';
        }
        else {
            return 'Running user DOES NOT HAVE the DW_Symbol_Search perm';
        }
    }

}
