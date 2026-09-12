/// Riverpod 3는 Provider가 실패하면 기본으로 최대 10회 지수 백오프 재시도를 한다.
/// 그동안 상태가 AsyncError가 아니라 AsyncLoading이라 화면에 에러가 보이지 않는다.
/// 이 앱은 자동 재시도를 쓰지 않고, 실패를 즉시 화면에 보여준 뒤 사용자가 다시 시도한다.
/// 서버 데이터 Provider에는 `@Riverpod(retry: noRetry)`를 붙인다.
Duration? noRetry(int retryCount, Object error) => null;
