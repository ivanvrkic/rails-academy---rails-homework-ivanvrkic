module Api
  class CompaniesController < ApplicationController
    def index
      render json: jsonapi_serializer? ? jsonapi_company(Company.all) : blueprinter_all_companies
    end

    def show
      company = Company.find(params[:id])
      render json: if jsonapi_serializer?
                     jsonapi_company(company)
                   else
                     default_json_company(company)
                   end
    end

    def create
      company = Company.new(company_params)
      if company.save
        render json: default_json_company(company), status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def update
      company = Company.find(params[:id])
      if company.update(company_params)
        render json: default_json_company(company), status: :ok
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def destroy
      company = Company.find(params[:id])
      if company.destroy
        render json: company, status: :no_content
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    private

    def company_params
      params.require(:company).permit(:id, :name)
    end

    def default_json_company(company)
      CompanySerializer.render(company, root: :company, view: :normal)
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
