String formatDuration(Duration d) {
  if (d.inMinutes == 0) return d.inSeconds.toString();
  int seconds = d.inSeconds - (d.inMinutes * Duration.secondsPerMinute);
  return '${d.inMinutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
}
