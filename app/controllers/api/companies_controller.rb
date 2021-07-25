module Api
  class CompaniesController < ApplicationController
    def index
      render json: jsonapi_serializer? ? jsonapi_all_companies : blueprinter_all_companies
    end

    def show
      company = Company.find(params[:id])
      render json: if jsonapi_serializer?
                     jsonapi_company(company)
                   else
                     CompanySerializer.render(
                       company, root: :company
                     )
                   end
    end

    def create
      company = Company.new(company_params)
      if company.save
        render json: CompanySerializer.render(company, root: :company), status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def update
      company = Company.find(params[:id])
      if company&.update(company_params)
        render json: CompanySerializer.render(company, root: :company), status: :ok
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def destroy
      company = Company.find(params[:id])
      if company&.destroy
        render json: company, status: :no_content
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    private

    def company_params
      params.require(:company).permit(:id, :name)
    end

    def jsonapi_all_companies
      JsonapiSerializer::CompanySerializer.new(Company.all).public_send(json_root_method)
    end

    def jsonapi_company(company)
      JsonapiSerializer::CompanySerializer.new(company).json_with_root
    end

    def blueprinter_all_companies
      if root?
        CompanySerializer.render(Company.all,
                                 root: :companies)
      else
        CompanySerializer.render(Company.all)
      end
    end
  end
end
