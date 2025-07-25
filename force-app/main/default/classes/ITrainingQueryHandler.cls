/**
 * @description An interface that all specialized training query handlers must implement.
 */
public interface ITrainingQueryHandler {
    String process(TrainingQueryRequest queryRequest);
}