import '../../../core/data/datasources/request_remote_data_source.dart';
import '../../../core/models/service_request.dart';

class DashboardRepository {
  final RequestRemoteDataSource _dataSource = RequestRemoteDataSource();

  Stream<List<ServiceRequest>> getServiceRequests() {
    return _dataSource.getServiceRequestsStream();
  }
}