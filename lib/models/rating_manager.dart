class RatingManager {
  static int calculatePopularity(int currentPopularity, int rating,
      int foodWeight, int restaurantWeight, int positionIndex) {
    int newPopularity = (currentPopularity +
            (rating * (foodWeight + restaurantWeight) * positionIndex))
        .toInt();
    return newPopularity;
  }
}
