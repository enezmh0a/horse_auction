function pics(lotId) {
  return [
    `https://picsum.photos/seed/${lotId}-1/1024/768`,
    `https://picsum.photos/seed/${lotId}-2/1024/768`,
    `https://picsum.photos/seed/${lotId}-3/1024/768`,
    `https://picsum.photos/seed/${lotId}-4/1024/768`,
  ];
}

function lot(lotId, title, startPrice, minIncrement, city, cluster, closeInMin, horse) {
  const closeAt = Timestamp.fromMillis(Date.now() + closeInMin * 60 * 1000);
  return {
    lotId, title, city, cluster,
    startPrice, minIncrement, status: "live",
    currentHighest: 0, currentHighestUserId: null, bidsCount: 0,
    closeAt, createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
    horse,
    images: pics(lotId), // <-- add this
    videos: [],
  };
}
