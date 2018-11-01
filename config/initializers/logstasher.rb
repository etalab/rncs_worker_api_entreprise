if LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    fields[:type] = 'rncs'
  end

  LogStasher.add_custom_fields_to_request_context do |fields|
    controller_name = request.params['controller']

    # TODO activate me when there is API VERSIONING
    #is_api_request =
    #  controller_name =~ /\Aapi\//

    #if is_api_request
    #  fields[:api_version] = controller_name.split('/')[1]
    #end
  end
end

