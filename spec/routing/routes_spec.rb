# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'spec_helper'

describe 'routing' do
  it 'routes / to application#index' do
    { get: '/' }.should route_to('application#index')
  end

  it 'routes /browse/:letter to formulae#browse' do
    { get: '/browse/a' }.should route_to(
      'formulae#browse',
      letter: 'a'
    )
  end

  it 'routes /browse/:letter/:page to formulae#index' do
    { get: '/browse/a/2' }.should route_to(
      'formulae#browse',
      letter: 'a',
      page: '2'
    )
  end

  it 'routes /search/:search to formulae#browse' do
    { get: '/search/git' }.should route_to(
      'formulae#browse',
      search: 'git'
    )
  end

  it 'routes /search/:search/:page to formulae#browse' do
    { get: '/search/git/2' }.should route_to(
      'formulae#browse',
      search: 'git',
      page: '2'
    )
  end

  it 'routes /formula/:name to formulae#show for name' do
    { get: '/formula/git' }.should route_to(
      'formulae#show',
      id: 'git'
    )
  end

  it 'routes /feed.atom to formulae#feed' do
    { get: '/feed.atom' }.should route_to('formulae#feed', format: 'atom')
  end

  it 'routes /repos/adamv/homebrew-alt/browse/:letter to formulae#browse' do
    { get: '/repos/adamv/homebrew-alt/browse/a' }.should route_to(
      'formulae#browse',
      letter: 'a',
      repository_id: 'adamv/homebrew-alt'
    )
  end

  it 'routes /repos/adamv/homebrew-alt/browse/:letter/:page to formulae#browse' do
    { get: '/repos/adamv/homebrew-alt/browse/a/2' }.should route_to(
      'formulae#browse',
      letter: 'a',
      page: '2',
      repository_id: 'adamv/homebrew-alt'
    )
  end

  it 'routes /repos/adamv/homebrew-alt/search/:search to formulae#browse' do
    { get: '/repos/adamv/homebrew-alt/search/git' }.should route_to(
      'formulae#browse',
      repository_id: 'adamv/homebrew-alt',
      search: 'git'
    )
  end

  it 'routes /repos/adamv/homebrew-alt/search/:search/:page to formulae#browse' do
    { get: '/repos/adamv/homebrew-alt/search/git/2' }.should route_to(
      'formulae#browse',
      repository_id: 'adamv/homebrew-alt',
      search: 'git',
      page: '2'
    )
  end

  it 'routes /repos/adamv/homebrew-alt/formula/:name to formulae#show for name' do
    { get: '/repos/adamv/homebrew-alt/formula/git' }.should route_to(
      'formulae#show',
      id: 'git',
      repository_id: 'adamv/homebrew-alt'
    )
  end

  it 'routes /repos/adamv/homebrew-alt/feed.atom to formulae#feed' do
    { get: '/repos/adamv/homebrew-alt/feed.atom' }.should route_to(
      'formulae#feed',
      format: 'atom',
      repository_id: 'adamv/homebrew-alt'
    )
  end

  it 'routes /sitemap.xml to application#sitemap' do
    { get: '/sitemap.xml' }.should route_to('application#sitemap', format: 'xml')
  end

  it 'routes unknown URLs to application#not_found' do
    { get: '/unknown' }.should route_to('application#not_found', url: 'unknown')
  end
end
