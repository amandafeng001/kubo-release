# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'yaml'

describe 'kubelet_ctl' do
  let(:rendered_template) { compiled_template('kubelet', 'bin/kubelet_ctl', {}, {}, {}, 'z1') }

  it 'labels the kubelet with its own az' do
    expect(rendered_template).to include(',failure-domain.beta.kubernetes.io/zone=z1')
  end

  it 'has no http proxy when no proxy is defined' do
    rendered_kubelet_ctl = compiled_template(
      'kubelet',
      'bin/kubelet_ctl',
      {}
    )

    expect(rendered_kubelet_ctl).not_to include('export http_proxy')
    expect(rendered_kubelet_ctl).not_to include('export https_proxy')
    expect(rendered_kubelet_ctl).not_to include('export no_proxy')
  end

  it 'sets http_proxy when an http proxy is defined' do
    rendered_kubelet_ctl = compiled_template(
      'kubelet',
      'bin/kubelet_ctl',
      'http_proxy' => 'proxy.example.com:8090'
    )

    expect(rendered_kubelet_ctl).to include('export http_proxy=proxy.example.com:8090')
  end

  it 'sets https_proxy when an https proxy is defined' do
    rendered_kubelet_ctl = compiled_template(
      'kubelet',
      'bin/kubelet_ctl',
      'https_proxy' => 'proxy.example.com:8100'
    )

    expect(rendered_kubelet_ctl).to include('export https_proxy=proxy.example.com:8100')
  end

  it 'sets no_proxy when no proxy property is set' do
    rendered_kubelet_ctl = compiled_template(
      'kubelet',
      'bin/kubelet_ctl',
      'no_proxy' => 'noproxy.example.com,noproxy.example.net'
    )

    expect(rendered_kubelet_ctl).to include('export no_proxy=noproxy.example.com,noproxy.example.net')
    expect(rendered_kubelet_ctl).to include('export NO_PROXY=noproxy.example.com,noproxy.example.net')
  end
end
