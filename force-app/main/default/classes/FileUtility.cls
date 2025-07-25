public abstract class FileUtility {
	public static sObject[] parseCSVToRecords(final String data, final String sObjectType) {
		final String[] dataArray = data.split('\n');
		final String[] fieldNames = dataArray.remove(0).trim().split(',');
		final Schema.sObjectType newSObject = Schema.getGlobalDescribe().get(sObjectType);
		final sObject[] newRecords = new sObject[]{};

		while (0 < dataArray.size()) {
			final sObject record = newSObject.newSObject();
			final String[] stringRecord = dataArray.remove(0).split(',');

			for (Integer j = 0; j < fieldNames.size(); j++) {

				record.put(fieldNames[j],	stringRecord[j].remove('\r'));
			}

			newRecords.add(record);
		}

		return newRecords;
	}
}