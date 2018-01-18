/**
 *  FeatureParameterReader
**/

public virtual class FeatureParameterReader {

	/**
	 * This default constructor will seek out all unmanaged/default namespace Custom Permissions 
	 **/
	public FeatureParameterReader() {
		return;
	}


    public boolean hasFeature(String featureParameterName) {
        return FeatureManagement.checkPackageBooleanValue(featureParameterName);
    }

    public void setBooleanFeature(String featureParameterName, Boolean featureParameterValue) {
        FeatureManagement.setPackageBooleanValue(featureParameterName, featureParameterValue);
        return;
    }



	/**
	 * This constructor will load Custom Permissions associated with the namespace of the object passed in,
	 *   this is the best constructor to use if you are developing a managed AppExchange package! The object 
	 *   passed in does not matter so long as its one from the package itself.
	 *
	 *   If the object is running in a managed context (e.g. packaging org or installed package) namespace is used to constrain the query 
	 *   If the object is not running in a managed context (e.g. developer org not namespaced) the default namespace is used to query
	 **/
    /*
	public CustomPermissionsReader(SObjectType managedObject) {
		this.managedObject = managedObject;
	}
    //*/
    /*
	public Boolean hasPermission(String customPermissionName) {
		// Demand load the custom permissions from the database?		
		if(customPermissionNames==null)
			init();
		// Is this a valid custom permission name?
		if(!customPermissionNames.contains(customPermissionName))
			throw new CustomPermissionsException('Custom Permission ' + customPermissionName + ' is not valid.');
		// Has this user been assigned this custom permission?
		return customPermissionsForCurrentUser.contains(customPermissionName);
	}
    //*/
	/**
	 * Loads Custom Permissions sets for either the default namespace or 
	 *   the current namespace context (derived from the managed object reference)
	 **/
    /*
	private void init() {

		customPermissionNames = new Set<String>();
		customPermissionsForCurrentUser = new Set<String>();

		// Determine the namespace context for the custom permissions via the SObject passed in?
		String namespacePrefix = null;
		if(managedObject!=null) {
			DescribeSObjectResult describe = managedObject.getDescribe();
			String name = describe.getName();
			String localName = describe.getLocalName();
			namespacePrefix = name.removeEnd(localName).removeEnd('__');
		}

		// Query the full set of Custom Permissions for the given namespace
		Map<Id, String> customPermissionNamesById = new Map<Id, String>();
		List<CustomPermission> customPermissions = 
			[select Id, DeveloperName from CustomPermission where NamespacePrefix = :namespacePrefix];
		for(CustomPermission customPermission : customPermissions) {
			customPermissionNames.add(customPermission.DeveloperName);
			customPermissionNamesById.put(customPermission.Id, customPermission.DeveloperName);
		}

		// Query to determine which of these custome settings are assigned to this user
		List<SetupEntityAccess> setupEntities = 
			[SELECT SetupEntityId
				FROM SetupEntityAccess
				WHERE SetupEntityId in :customPermissionNamesById.keySet() AND
					  ParentId
						IN (SELECT PermissionSetId 
   							FROM PermissionSetAssignment
   							WHERE AssigneeId = :UserInfo.getUserId())];	
		for(SetupEntityAccess setupEntity : setupEntities)
			customPermissionsForCurrentUser.add(customPermissionNamesById.get(setupEntity.SetupEntityId));	
	}
    //*/
	public class FeatureParametersException extends Exception {}
}