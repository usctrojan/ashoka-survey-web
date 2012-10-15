# Interfaces between the views and the rails model for an option
class SurveyBuilder.Models.OptionModel extends Backbone.RelationalModel
  urlRoot: '/api/options'
  defaults: {
    content: 'untitled'
  }

  initialize: ->
    @sub_question_order_counter = 0
    @sub_question_models = []

  has_errors: ->
    !_.isEmpty(this.errors)

  save_model: ->
    this.save({}, {error: this.error_callback, success: this.success_callback})
    _.each @sub_question_models, (question) ->
      question.save_model()

  success_callback: (model, response) =>
    this.errors = []
    this.trigger('change:errors')

  error_callback: (model, response) =>
    this.errors = JSON.parse(response.responseText)
    this.trigger('change:errors')

  next_sub_question_order_number: ->
    @sub_question_order_counter++

  add_sub_question: (type) ->
    sub_question_model = new SurveyBuilder.Models.QuestionModel({ type: type, parent_id: this.id, survey_id: this.get('question').get('survey_id') })
    @sub_question_models.push sub_question_model 
    this.trigger('add:sub_question', sub_question_model)

  set_questions: ->
    _.each this.get('questions'), (question) =>
      question_model = new SurveyBuilder.Models.QuestionModel({ id: question.id })
      question_model.fetch()
      @sub_question_models.push question_model
    this.trigger('change:preload_questions', @sub_question_models)

SurveyBuilder.Models.OptionModel.setup()

# Collection of all options for radio question
class SurveyBuilder.Collections.OptionCollection extends Backbone.Collection
  model: SurveyBuilder.Models.OptionModel

  url: ->
    '/api/options?question_id=' + this.question.id

  has_errors: ->
    this.any((option) -> option.has_errors())
 
  set_questions: ->
    _.each this.models, (option_model) ->
      option_model.set_questions()
