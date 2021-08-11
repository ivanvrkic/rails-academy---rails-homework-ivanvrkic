module Api
  module Statistics
    class CompaniesController < ApplicationController
      def index
        company = CompaniesQuery.new.with_stats
        authorize [:statistics, company]
        render json: default_json_company(company)
      end

      private

      def default_json_company(company)
        if root?
          root_name = company.is_a?(Company) ? :company : :companies
          Statistics::CompanySerializer.render(company, root: root_name)
        else
          Statistics::CompanySerializer.render(company)
        end
      end
    end
  end
end
