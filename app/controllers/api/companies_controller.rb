module Api
  class CompaniesController < ApplicationController
    skip_before_action :auth, only: [:index, :show]

    def index
      company = if params[:filter] == 'active'
                  Company.joins(:flights)
                         .where('flights.departs_at > ?', DateTime.now)
                         .distinct
                         .order(name: :asc)
                else
                  Company.order(name: :asc)
                end
      company = company.includes(:flights) unless jsonapi_serializer?
      render json: response_company(company)
    end

    def show
      company = Company.find(params[:id])
      render json: response_company(company)
    end

    def create
      company = Company.new(company_params)

      authorize company

      if company.save
        render json: default_json_company(company), status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def update
      company = Company.find(params[:id])

      authorize company

      if company.update(company_params)
        render json: default_json_company(company), status: :ok
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def destroy
      company = Company.find(params[:id])

      authorize company

      if company.destroy
        render json: company, status: :no_content
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    private

    def response_company(company)
      if jsonapi_serializer?
        jsonapi_company(company)
      else
        default_json_company(company)
      end
    end

    def company_params
      params.require(:company).permit(:id, :name)
    end

    def default_json_company(company)
      if root?
        root_name = company.is_a?(Company) ? :company : :companies
        CompanySerializer.render(company, root: root_name, view: :normal)
      else
        CompanySerializer.render(company, view: :normal)
      end
    end

    def jsonapi_company(company)
      JsonapiSerializer::CompanySerializer.new(company).public_send(json_root_method)
    end

    def blueprinter_all_companies
      if root?
        CompanySerializer.render(Company.all, root: :companies, view: :normal)
      else
        CompanySerializer.render(Company.all, view: :normal)
      end
    end
  end
end
