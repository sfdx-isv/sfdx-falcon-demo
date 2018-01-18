<aura:application extends="force:slds">
    <aura:attribute name="recordId" type="Id" default="001Z000001IBkVj" />
    <aura:attribute name="debug" type="Boolean" default="true" />
    <aura:attribute name="debugClient" type="Boolean" default="true" />
   <!-- <c:DWSearchInstrument debug="{!v.debug}" debugClient="{!v.debugClient}" recordId="{!v.recordId}" allowOrderPlacement="false" />
    <c:DWCreateMarketOrder debug="{!v.debug}" recordId="{!v.recordId}" debugClient="{!v.debugClient}" />
    <c:DWOrderList debug="{!v.debug}" debugClient="{!v.debugClient}" recordId="{!v.recordId}" />
    -->
    <!--
    <c:DWSearchInstrument debug="{!v.debug}" debugClient="{!v.debugClient}" recordId="{!v.recordId}" allowOrderPlacement="false" />
    <c:DWCreateMarketOrder debug="{!v.debug}" recordId="{!v.recordId}" debugClient="{!v.debugClient}" />
    <c:DWCreateAccountForm recordId="{!v.recordId}" debug="{!v.debug}" debugClient="{!v.debugClient}"  />
    -->

    <c:DWCreateAccountForm debug="{!v.debug}" debugClient="{!v.debugClient}" recordId="{!v.recordId}" />
    
    
    <c:DWOrderList debug="{!v.debug}" debugClient="{!v.debugClient}" recordId="{!v.recordId}" />

</aura:application>