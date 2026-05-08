import 'dart:async';

typedef DebouncedBoolApply<K> = void Function(K key, bool value);
typedef DebouncedBoolPerform<K> = Future<bool> Function(K key);

class DebouncedBoolActionController<K> {
  final Duration debounce;
  final DebouncedBoolApply<K> apply;
  final DebouncedBoolPerform<K> perform;
  final void Function(K key)? onSettled;

  final Map<K, _PendingBoolJob> _jobs = {};

  DebouncedBoolActionController({
    required this.debounce,
    required this.apply,
    required this.perform,
    this.onSettled,
  });

  void toggle(K key, {required bool currentValue}) {
    final nextValue = !currentValue;
    final job = _jobs[key] ?? _PendingBoolJob(confirmedValue: currentValue);

    job.desiredValue = nextValue;
    job.timer?.cancel();
    _jobs[key] = job;

    apply(key, nextValue);
    job.timer = Timer(debounce, () => _flush(key));
  }

  void dispose() {
    for (final job in _jobs.values) {
      job.timer?.cancel();
    }
    _jobs.clear();
  }

  Future<void> _flush(K key) async {
    final job = _jobs[key];
    if (job == null || job.inFlight) return;

    if (job.desiredValue == job.confirmedValue) {
      job.timer = null;
      _jobs.remove(key);
      onSettled?.call(key);
      return;
    }

    job.timer = null;
    job.inFlight = true;

    try {
      final confirmedValue = await perform(key);
      job.confirmedValue = confirmedValue;
      apply(key, confirmedValue);
    } catch (_) {
      job.desiredValue = job.confirmedValue;
      apply(key, job.confirmedValue);
    } finally {
      job.inFlight = false;
      final current = _jobs[key];
      if (current != null) {
        if (current.desiredValue != current.confirmedValue) {
          current.timer?.cancel();
          current.timer = Timer(debounce, () => _flush(key));
        } else if (current.timer == null) {
          _jobs.remove(key);
          onSettled?.call(key);
        }
      }
    }
  }
}

class _PendingBoolJob {
  bool confirmedValue;
  bool desiredValue;
  bool inFlight;
  Timer? timer;

  _PendingBoolJob({required this.confirmedValue})
    : desiredValue = confirmedValue,
      inFlight = false;
}
