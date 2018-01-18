public class Application {
    /**
     * Expoeses typed representation of the Applications Custom Permissions
     **/
    public static final PermissionsFactory      Permissions = new PermissionsFactory();
    public static final FeatureParameterFactory Features    = new FeatureParameterFactory();
 
    /**
     * Class provides a typed representation of an Applications Custom Permissions
     **/
    public class PermissionsFactory extends CustomPermissionsReader
    {
        public Boolean DW_Symbol_Search { get { return hasPermission('DW_Symbol_Search'); } }
    }

    public class FeatureParameterFactory extends FeatureParameterReader
    {
        public Boolean SymbolSearchEnabled 
        { 
            get { return hasFeature('SymbolSearchEnabled'); } 
            set { setBooleanFeature('SymbolSearchEnabled', value); }
        }

        public Boolean SymbolSearchPermitted 
        { 
            get { return hasFeature('SymbolSearchPermitted'); } 
            set { setBooleanFeature('SymbolSearchPermitted', value); }
        }
        
    }
}