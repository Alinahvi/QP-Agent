public class SimpleTestInvocable {
    @InvocableMethod(
        label='Simple Test Action'
        description='A simple action to test if invocable methods can be saved.'
    )
    public static List<String> execute(List<String> inputs) {
        return new List<String>{'Hello'};
    }
}