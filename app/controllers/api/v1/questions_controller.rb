module Api
  module V1
    class QuestionsController < APIApplicationController
      before_filter :dont_cache

      def create
        question = Question.new_question_by_type(params[:question][:type], params[:question])
        authorize! :update, question.survey
        if question.save
          render :json => question.to_json(:methods => [:type, :has_multi_record_ancestor])
        else
          render :json => question.errors.full_messages, :status => :bad_request
        end
      end

      def update
        question = Question.find(params[:id])
        authorize! :update, question.survey
        if question.update_attributes(params[:question])
          render :json => question.to_json(:methods => :type)
        else
          render :json => question.errors.full_messages, :status => :bad_request
        end
      end

      def destroy
        question = Question.find(params[:id])
        authorize! :update, question.survey
        begin
          Question.destroy(params[:id])
          render :nothing => true
        rescue ActiveRecord::RecordNotFound
          render :nothing => true, :status => :bad_request
        end
      end

      def image_upload
        question = Question.find(params[:id])
        authorize! :update, question.survey
        question.update_attributes({ :image => params[:image] })
        if question.save
          render :json => { :image_url => question.image_url }
        else
          render :json => { :errors => question.errors }
        end
      end

      def index
        survey = Survey.find_by_id(params[:survey_id])
        authorize! :read, survey
        methods = [:type, :image_url]
        methods << :image_in_base64 if request.referrer.nil?
        if survey
          render :json => survey.first_level_questions.to_json(:methods => methods)
        else
          render :nothing => true, :status => :bad_request
        end
      end

      def show
        question = Question.find_by_id(params[:id])
        authorize! :read, question.survey
        methods = [:type, :image_url, :has_multi_record_ancestor]
        methods << :image_in_base64 if request.referrer.nil?
        if question
          render :json => question.to_json(:methods => methods)
        else
          render :nothing => true, :status => :bad_request
        end
      end

      def duplicate
        question = Question.find_by_id(params[:id])
        authorize! :edit, question.survey
        if question && question.copy_with_order
          flash[:notice] = t("flash.question_duplicated")
        else
          flash[:error] = t("flash.question_duplication_failed")
        end
        redirect_to :back
      end

      private
      def dont_cache
        expires_now
      end
    end
  end
end
