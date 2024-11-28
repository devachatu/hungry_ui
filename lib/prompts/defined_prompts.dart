class DefinedPrompts {
  static final String SEARCH_FROM_INGREDIENTS =
      """Give me a list of 10 dishes that I can make using the following ingredients (also consider indian dishes):[{ingredients}]. 
      Give me the response in a JSON format with a list of objects with title, calories, time, description and suggestions for more ingredients
      
      """;

  static final String DISH_INGREDIENTS_DETAILS =
      """Give me a list of ingredients to prepare the dishes {dish_name} for {quantity} people
      Give me the response in a JSON format with a list of objects with name, size
      """;

  static final String DISH_TUTORIAL_DETAILS =
      """Give me a list of detailed tutorial steps to prepare the dish {dish_name} for {quantity} people
      Give me the response in a JSON format with a list of objects with step title as 'step', description, warnings and additional notes.
      SAMPLE FORMAT
      ```
      [
      {
        'step': '1. Tuangkan Air.',
        'description':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat',
        'warnings':"check oil might be hot",
        'additional_notes:" add salt to taste",
      },
    ]
      ```
      """;

  static final String DISH_REVIEW_DETAILS =
      """Give me a list of detailed reviews the dish {dish_name}.
       Give me the response in a JSON format with a list of objects with 'username', 'review'.
      SAMPLE FORMAT
      ```
      [
      {
        'username': '@username',
        'review':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      },
    ]
      ```
      """;
}
