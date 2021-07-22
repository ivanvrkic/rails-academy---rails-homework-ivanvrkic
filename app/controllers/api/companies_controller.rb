module Api
  class CompaniesController < ApplicationController
    def index
      render json: CompanySerializer.render(Company.all, root: :companies)
    end

    def show
      company = Company.find(params[:id])
      if company
        render json: CompanySerializer.render(company, root: :company)
      else
        render json: { errors: 'not found' }, status: :not_found
      end
    end

    def create
      company = fCompany.new(company_params)
      if company.save
        render json: company, status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def update
      company = Company.find(params[:id])
      if company&.update(company_params)
        render json: company, status: :ok
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    def destroy
      company = Company.find(params[:id])
      if company&.destroy
        render json: company, status: :ok
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    private

    def company_params
      params.require(:company).permit(:id, :name)
    end
  end
end
