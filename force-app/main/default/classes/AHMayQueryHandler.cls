public interface AHMayQueryHandler {
    AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData);
}