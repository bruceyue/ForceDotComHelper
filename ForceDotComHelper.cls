/*
 * This class aimed to prepare some useful methods for your Force.com Applications.
 */
public class ForceDotComHelper
{
	//forward everything information to me
	public static void forwardEverythingToMe(Messaging.InboundEmail email)
    {
        Messaging.SingleEmailMessage forwardingMail = new Messaging.SingleEmailMessage();
        forwardingMail.setToAddresses(new String[] { 'bruce.yue@meginfo.com' }); //we can set CTO's email address
        forwardingMail.setSubject(email.subject);
        forwardingMail.setPlainTextBody(email.plainTextBody);
        forwardingMail.setHtmlBody(email.htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { forwardingMail });
    }
	
	//sends an email with plaintext body to the specified addresses.
    public static void sendSimpleEmail(String[] toAddresses, String subject, String body)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
        mail.setToAddresses(toAddresses);     
        mail.setSaveAsActivity(false);
        mail.setSubject(subject);
        mail.setPlaintextBody(body);
		mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
    }

	//value can not be null and empty
	public static Boolean notNullAndEmpty(String value)
   	{
        return (value != null && value != '');
   	}

	// Gets the sObject describe result for the current object
	public static Map<String, Schema.DescribeFieldResult> describeObject(String objectName)
    {
        Map<String, Schema.DescribeFieldResult> fieldDescribeMap = new Map<String, Schema.DescribeFieldResult>();
		//Use the Schema getGlobalDescribe method to return a map that represents the relationship between all sObject names (keys) to sObject tokens (values)
        Map<String, Schema.sObjectType> globalDescribe = Schema.getGlobalDescribe();
        if(globalDescribe.containsKey(objectName))
        {
			//Use the field describe result's getMap method to return a map that represents the relationship between all the field names (keys) and the field tokens (values) for an sObject.		    
            Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(objectName).getDescribe().fields.getMap();
            for(String fieldName : fieldMap.keySet())
            {
                Schema.sObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                fieldDescribeMap.put(fieldName, fieldDescribe); 
            }
        }
		return fieldDescribeMap;
    }

	//  Gets all child objects name
	//  e.g: SObject obj = new Account();
	//  Schema.SObjectType is the data type for an sObject token.
	public static List<Schema.SObjectType> getChildObjects(SObject obj)
	{
		List<Schema.SObjectType> sObjectTypes = new List<Schema.SObjectType>();
		if(obj != null)
		{
			Schema.DescribeSObjectResult result = obj.getSObjectType().getDescribe();
			List<Schema.ChildRelationship> childs = result.getChildRelationships();
			for(Schema.ChildRelationship child : childs)
			{
				sObjectTypes.add(child.getChildSObject());
			}
		}	
		return sObjectTypes;
	}
	
	//Account -> Contacts
	public static String getChildQueryRelationShipName(String childObj, String parentObj)
	{
		String childRelationName = '';
		Map<String, Schema.sObjectType> globalDescribe = Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult results = globalDescribe.get(parentObj).getDescribe();
		List<Schema.ChildRelationship> childs = results.getChildRelationships();
		for(Schema.ChildRelationship child : childs)
		{
			if(String.valueof(child.getChildSObject()) == childObj)
			{
				childRelationName = child.getRelationshipName();
				break;
			}				
		} 
		return childRelationName;	
	}
	
	//String objectName ='Account'; String fieldName = 'Account's field';
	public static Boolean isLookUpField(String objectName, String fieldName)
	{
		Boolean result = false;
		Map<String, Schema.sObjectType> globalDescribe = Schema.getGlobalDescribe();
		if(globalDescribe.containsKey(objectName))
		{
			//Use the field describe result's getMap method to return a map that represents the relationship between all the field names (keys) and the field tokens (values) for an sObject.		    
		    Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(objectName).getDescribe().fields.getMap();
	        Schema.sObjectField field = fieldMap.get(fieldName);
	        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
			if(fieldDescribe.getType() == Schema.DisplayType.Reference)   // look up field
			{
				system.debug('**'+String.valueof(fieldDescribe.getReferenceTo()));
				result = true;
			} 
		}
		return result;
	}

	//  Returns the name of the relationship.
	public static Set<String> getRelationshipNames(String obj) //obj = parent object
	{
		Set<String> relationshipNames = new Set<String>();
		if(notNullAndEmpty(obj))
		{
			Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
			Schema.DescribeSObjectResult results = globalDescribe.get(obj).getDescribe();
			List<Schema.ChildRelationship> childs = results.getChildRelationships();
			for(Schema.ChildRelationship child : childs)
			{
				relationshipNames.add(child.getRelationshipName());
			}
		}
		return relationshipNames;
	}
	
	//Returns the three-character prefix code for the object. 
	public static String getSobjectIdPrefix(SObject obj)
	{
		String prefix = '';
		if(obj != null)
		{
			Schema.DescribeSObjectResult result = obj.getSObjectType().getDescribe();
			prefix = result.getKeyPrefix();
		}		
		return prefix;
	}
	
	//Returns the Sobject name from three-character prefix of the object Id. 
	public static String getSobjectNameFromIdPrefix(String objId)
	{
		String objectName = '';
		if(notNullAndEmpty(objId))
		{
			String prefix = objId.subString(0, 3);
			Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
			for(Schema.SObjectType objectInstance : globalDescribe.values())
			{
				if(objectInstance.getDescribe().getKeyPrefix() == prefix)
				{	
					objectName = objectInstance.getDescribe().getName();
				}
			}			
		}
		return objectName;	
	}
	
	// Gets picklist field values, e.g: Schema.Describefieldresult fieldResult = Opportunity.Type.getDescribe();
	public static List<SelectOption> getPicklistValues(Schema.Describefieldresult fieldResult)
    {
       	List<SelectOption> options = new List<SelectOption>();
		options.add('', '--None--');
		List<Schema.PickListEntry> pickListEntries = fieldResult.getPickListValues();       
		for(Schema.PickListEntry entry : pickListEntries)
		{
		   	options.add(new SelectOption(entry.getValue(), entry.getLabel()));
		}
		return options;    
    }

	//Gets the default value of picklist
	public static String getDefaultPicklistValue(SObject obj, Schema.DescribeFieldResult fieldDescribe) 
    {
        String key = obj.getSObjectType() + '.' + fieldDescribe.getName();
        if(!DefaultPicklistValue.containsKey(key)) 
        {
            List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
            String value = null;
            for(Schema.Picklistentry entry : entries) 
            {
                if(entry.isDefaultValue()) // TODO check for entry.isActive() here
                {
                    value = entry.getValue();
                    break;
                }
            }
            if(value == null)  // if somehow no default value is there
            {
            	value = entries.size() > 0 ? entries[0].getValue() : null;
            }
            DefaultPicklistValue.put(key, value);
        }  
        return DefaultPicklistValue.get(key); 
    }
	
	// Sets sObject's record type.
	public static void setRecordType(SObject obj) 
    {
		//A RecordTypeInfo object is returned from the sObject describe result using the getRecordTypeInfos method
        List<Schema.RecordTypeInfo> recordTypes = obj.getSObjectType().getDescribe().getRecordTypeInfos();
        if(recordTypes.size() > 1) 
        { 
        	// all objects have default Master type
            for(Schema.RecordTypeInfo recordType : recordTypes) 
            {
				// Returns true if this record type is available to the current user, false otherwise. Use this method to
				// display a list of available record types to the user when he or she is creating a new record.
                if(recordType.isAvailable() && recordType.isDefaultRecordTypeMapping()) 
                {
                    obj.put('RecordTypeId', recordType.getRecordTypeId());
                }
            }
        }
    }
	
    /*There are two versions of every record Id in salesforce :
	  15 digit case-sensitive version which is referenced in the UI,
	  18 digit case-insensitive version which is referenced through the API
	*/
	public static String convertIdFrom15To18(String Id)
	{
		String suffix = '';
		Integer flags;
		for(Integer i = 0; i < 3; i++)
		{
			flags = 0;
			for(Integer j = 0; j < 5; j++)
			{
				String c = Id.subString(i * 5 + j,i * 5 + j + 1);
				//Only add to flags if c is an uppercase letter:
				if(c.toUpperCase().equals(c) && c >= 'A' && c <= 'Z')
				{
					flags = flags + (1 << j);
				}
			}
			if(flags <= 25)
			{
				suffix = suffix + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.substring(flags,flags+1);
			}
			else
			{
				suffix = suffix + '012345'.substring(flags-25,flags-24);
			}
		}
		return Id + suffix;
	}
	
	//sorting a map by value, even if two values are the same, it works correctly.
	//  oldMap: { ID1=>20, ID2=>10, ID3=>40, ID4 => 40, ID5=>50 }
	// reverseMap : { 10=>ID2), 20=>ID1, 40=>(ID4, ID3), 50=>ID5 }
	public List<String> sortMap(Map<String, Integer> oldMap)   //return a list of sorted key
	{
		List<String> sortedKey = new List<String>();
		Map<Integer, List<String>> reverseMap =  new Map<Integer, List<String>>();
		List<String> tempList = new List<String>();
		if(oldMap.size() > 0)
		{
			for(String key : oldMap.KeySet())
			{
				if(reverseMap.containsKey(oldMap.get(key)))      
		   		{ 
		   			tempList = reverseMap.get(oldMap.get(key));
		   		}  
		   		else
				{
					tempList = new List<String>();
				}
		   		tempList.add(key);
		   		reverseMap.put(oldMap.get(key), tempList);
			}
			List<Integer> values = new List<Integer>(oldMap.values());
			values.sort();
			List<Integer> descValues = new List<Integer>();
			for(Integer i = values.size()-1; i >= 0;  i--)
			{
				descValues.add(values.get(i));
			}
			Set<Integer> sortValues = new Set<Integer>();
			for(Integer value : descValues)
			{
				if(!sortValues.contains(value))  // we don't need to get the same value again!
		   		{
		       		sortedKey.addAll(reverseMap.get(value));  
		       		sortValues.add(value);
		   		}
			}
		}
		return sortedKey;
	}
	
	// A method used to convert email's html body to text body
    // salesforce use "/n" to replace line breaks
    public static String convertHtmlToText(String htmlBody)
    {
		String result;
		if(htmlBody != null && htmlBody != '')
		{			
	        // Replace line breaks with space
	        // because browsers inserts space
	        result = htmlBody.replaceAll('\r', ' ');
	        result = result.replaceAll('\n', ' ');
	        // Remove step-formatting
	        result = result.replaceAll('\t', '');
	        // Remove repeating spaces because browsers ignore them
	        result = result.replaceAll('( )+', ' '); 
	        // remove the header
	        result = result.replaceAll('<( )*head([^>])*>', '<head>');
	        result = result.replaceAll('(<( )*(/)( )*head( )*>)', '</head>');
	        result = result.replaceAll('<(<head>).*(</head>)', '');
	        // remove all scripts (prepare first by clearing attributes)
	        result = result.replaceAll('<( )*script([^>])*>', '<script>');
	        result = result.replaceAll('(<( )*(/)( )*script( )*>)', '</script>');
	        result = result.replaceAll('(<script>).*(</script>)', '');
	        // remove all styles (prepare first by clearing attributes)
	        result = result.replaceAll('<( )*style([^>])*>', '<style>');
	        result = result.replaceAll('(<( )*(/)( )*style( )*>)', '</style>');       
	        result = result.replaceAll('(<style>).*(</style>)', '');
	        // insert tabs in spaces of <td> tags
	        result = result.replaceAll('<( )*td([^>])*>', '\t');
	        // insert line breaks in places of <BR> and <LI> tags
	        result = result.replaceAll('<( )*br([^>])*>', '\n');
	        result = result.replaceAll('<( )*li( )*>', '\n');
	        // insert line paragraphs (double line breaks) in place
	        // if <P>, <DIV> and <TR> tags
	        result = result.replaceAll('<( )*div([^>])*>', '\n\n');
	        result = result.replaceAll('<( )*tr([^>])*>', '\n\n');    
	        result = result.replaceAll('<( )*p([^>])*>', '\n\n');
	        // Remove remaining tags like <a>, links, images,
	        // comments etc - anything that's enclosed inside < >
	        result = result.replaceAll('<[^>]*>', '');
	        // replace special characters:
	        result = result.replaceAll(' ', ' ');
	        result = result.replaceAll('&bull;', ' * ');        
	        result = result.replaceAll('&lsaquo;', '<');
	        result = result.replaceAll('&rsaquo;', '>');
	        result = result.replaceAll('&trade;', '(tm)');
	        result = result.replaceAll('&frasl;', '/');
	        result = result.replaceAll('&lt;', '<');
	        result = result.replaceAll('&gt;', '>');
	        result = result.replaceAll('&copy;', '(c)');    
	        result = result.replaceAll('&reg;', '(r)');
	        result = result.replaceAll('&apos;', '\'');
	        result = result.replaceAll('&#39;', '\'');
	        result = result.replaceAll('&quot;', '"');
	        // Remove all others. More can be added, see
	        // http://hotwired.lycos.com/webmonkey/reference/special_characters/
	        result = result.replaceAll('&(.{2,6});', '');
	        // make line breaking consistent
	        result = result.replaceAll('\r', '\n');
	        // Remove extra line breaks and tabs:
	        // replace over 2 breaks with 2 and over 4 tabs with 4.
	        // Prepare first to remove any whitespaces in between
	        // the escaped characters and remove redundant tabs in between line breaks
	        result = result.replaceAll('(\n)( )+(\n)', '\n\n');    
	        result = result.replaceAll('(\t)( )+(\t)', '\t\t');
	        result = result.replaceAll('(\t)( )+(\n)', '\t\n');
	        result = result.replaceAll('(\n)( )+(\t)', '\n\t');   
	        // Remove redundant tabs
	        result = result.replaceAll('(\n)(\t)+(\n)', '\n\n');
	        // Remove multiple tabs following a line break with just one tab
	        result = result.replaceAll('(\n)(\t)+','\n\t');  
	        // Initial replacement target string for line breaks
	        String breaks = '\n\n\n';
	        // Initial replacement target string for tabs
	        String tabs = '\t\t\t\t\t';
	        for(Integer index = 0; index < result.Length(); index++)
	        {
	            result = result.replaceAll(breaks, '\n\n');
	            result = result.replaceAll(tabs, '\t\t\t\t');
	            breaks = breaks + '\n';
	            tabs = tabs + '\t';
	        }
	        // That's it.	        
		}   
		return result;
    }

	// Function to query any object,// Construct the list of fields
    // String[] flist  = new List<String>{'Name','Id'};
	// Call the runquery method to execute the query. Note that the condition has to be passed as an empty string if you do not have any condition
	// Account[] qresult = runQuery('Account',flist,'');
	public static List<sObject> runQuery(String objName,String[] fieldNames,String condition)
    {
        List<sObject> queryResult;
        String fieldsList = '';
        // Generate the fieldsList from the string array
        if(fieldNames != NULL)
        {
            if(fieldNames.size() > 0)
            {
                for (Integer i=0; i < fieldNames.size(); i++)
                {
                    if( i <= (fieldNames.size() - 2))
                        fieldsList = fieldsList + fieldNames[i]+',';
                    else
                        fieldsList = fieldsList + fieldNames[i];    
                }
            }
        } 
        // Construct the query string
        String soqlQuery = 'Select '+fieldsList+' from '+objName+' '+condition;
        queryResult = Database.query(soqlQuery);
        return queryResult;               
    }

	@isTest
	static void testForceDotComHelper()
	{
		ForceDotComHelper helper = new ForceDotComHelper();
	}
}