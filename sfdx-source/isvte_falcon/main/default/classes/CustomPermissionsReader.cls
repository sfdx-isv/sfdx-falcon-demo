/**
 * Copyright (c), Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * This class is designed to help with caching the results of querying (via SOQL) Custom Permissions for the 
 *   current user, it will load all defined Custom Permissions in one go for a given default or specified 
 *   namespace (so not all defined in the org). This is done on the basis the caller will make 2 or more calls to 
 *   the hasPermission method, thus benifiting from the bulkificaiton approach used. 
 *   Note that the query to the database is demand loaded only on the first call to the hasPermission method
 *   thus constructing the object carries no SOQL / database overhead.
 **/
public virtual class CustomPermissionsReader {

	private SObjectType managedObject;

	private Set<String> customPermissionNames;

	private Set<String> customPermissionsForCurrentUser;

	/**
	 * This default constructor will seek out all unmanaged/default namespace Custom Permissions 
	 **/
	public CustomPermissionsReader() {
		this(null);
	}

	/**
	 * This constructor will load Custom Permissions associated with the namespace of the object passed in,
	 *   this is the best constructor to use if you are developing a managed AppExchange package! The object 
	 *   passed in does not matter so long as its one from the package itself.
	 *
	 *   If the object is running in a managed context (e.g. packaging org or installed package) namespace is used to constrain the query 
	 *   If the object is not running in a managed context (e.g. developer org not namespaced) the default namespace is used to query
	 **/
	public CustomPermissionsReader(SObjectType managedObject) {
		this.managedObject = managedObject;
	}

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

	/**
	 * Loads Custom Permissions sets for either the default namespace or 
	 *   the current namespace context (derived from the managed object reference)
	 **/
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

	public class CustomPermissionsException extends Exception {}
}