public class stripTags {
    @InvocableMethod(label='Remove HTML Tags')
    public static List<String> removeHTMLTags(List<String> richTextList) {
        String richText = richTextList[0];
        List<String> plainTextList = new List<String>();
        richText = richText.stripHTMLTags();
        plainTextList.add(richText);
        return PlainTextList;
    }
}