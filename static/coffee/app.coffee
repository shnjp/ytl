global = @



# global = @
# #@is_on_web = if location.protocol == 'http:' then true else false
# @is_debug = false
# NCLIP_ROOT = "nclip://#{location.host}/"

# if !navigator.userAgent.match(/Mobile/)
#   @is_debug = true

# if @is_debug
#   NCLIP_ROOT = '/'

# ##### backbone classes
# CATEGORY_LABEL_MAP =
#   politics: '政治・外交'
#   economy: '経済'
#   financial_report: '決算'
#   social: '社会・スポーツ'


Photo = Backbone.Model.extend
  idAttribute: '_id'

  parse: (attrs) ->
    return _.from_mongo(attrs)

  get_thumbnail: (size) ->
    _.sortBy(@get('photos')[0]['alt_sizes'], (p) -> Math.abs(p.width - size))[0]


PhotoList = Backbone.Collection.extend
  model: Photo

  parse: (response) ->
    return response.photos

  load_more: (options) ->
    @fetch _.extend {
      update: true
      remove: false,
      data:
        skip: @length
    }, options || {}


TopPhotoList = PhotoList.extend
  url: '/photos'


PhotoView = Backbone.View.extend
  template: _.template($('#template-photo').html())

  render: (options) ->
    ctxt = _.extend({_view: @, options: options}, @.model)
    @$el.html(@template(ctxt))
    return @
  

PhotoListView = Backbone.View.extend
  initialize: (options) ->
    @loading = false
    @collection.on('add', @add_photo, @)
    @collection.on('reset', @reset_photo_list, @)

    @watch_tail()

    @$el
      .on('tail_reached', => @on_tail_reached())
      .masonry
        itemSelecotr: 'li'
        columnWidth: 250
        isFitWidth: true


  add_photo: (photo, collection, options) ->
    $new_node = $('<li class="photo" />')
    photoview = new PhotoView({el: $new_node, model: photo})
    photoview.render()

    @$el.append($new_node).masonry('appended', $new_node)

  reset_photo_list: (collection, options) ->
    collection.forEach (photo) =>
      @add_photo(photo, collection)

  load_more: ->
    if @loading
      return

    @collection.load_more
      success: (collection, resp, options) =>
        @$el.imagesLoaded =>
          @$el.masonry('reload')
      complete: (xhr, status) =>
        @loading = false

  on_tail_reached: () ->
    @load_more()

  watch_tail: () ->
    settings =
      threshold: 64
      container: window

    _test = ->
      height = $(document).height()
      bottom = $(window).height() + window.scrollY
      return if bottom > height - settings.threshold then true else false

    tail_reached = _test()

    # get_visible = -> !$.belowthefold(el, settings)
    # current_visible = null
    $(window).on 'scroll', =>
      if tail_reached
        if !_test()
          tail_reached = false
      else
        if _test()
          tail_reached = true
          @$el.trigger('tail_reached')


#   template: _.template($('#template-card-list-item').html())
#   card_view_class: CardView

#   initialize: (options) ->
#     @collection.on('add', @addCard, @)
#     @collection.on('reset', @resetCardList, @)

#     @$tail_loader = $('<li class="loader"><span></span></li>').appendTo(options.el)

#     @$tail_loader.on 'click, appear', =>
#       @load_next()

#     watch_appearing(@$tail_loader.get()[0])

#   addCard: (card, collection, options) ->
#     idx = collection.indexOf(card)
#     show_author = if idx > 0 and collection.at(idx - 1).get('user_id') == card.get('user_id') then false else true
#     ctxt = _.extend({card: card, show_author: show_author, _card: card.attributes})
#     $new_node = $(@template(ctxt))

#     cardview = new @card_view_class({el: $new_node.find('.card:first'), model: card})
#     cardview.render()
#     $new_node.insertBefore(@$tail_loader)

#   resetCardList: (collection, options) ->
#     collection.forEach (card) =>
#       @addCard(card, collection)
#     if collection.length == 0
#       @$tail_loader.hide()

#   load_next: ->
#     @$tail_loader.addClass('loading')
#     @collection.load_more
#       success: (collection, resp, options) =>
#         if resp.timeline.length == 0
#           @$tail_loader.hide()
#       complete: (xhr, status) =>
#         @$tail_loader.removeClass('loading')


#   ###
#   clipped cardだけにしたり、しなかったり  
#   ###
#   toggle_filter_cliped_cards: (show) ->
#     $targets = @$el.find('.card:not(.card-clipped)')

#     # toggleOn = @$el.is('.hide_nonclipped_cards')

#     if show
#       $targets.slideDown();
#       @$el.removeClass('hide_nonclipped_cards');
#     else
#       $targets.slideUp();
#       @$el.addClass('hide_nonclipped_cards');


# Card = Backbone.Model.extend
#   idAttribute: '_id'
#   urlRoot: '/card'

#   initialize: (options) ->
#     @source_card = new Card(options.source_card) if options.source_card?

#   get_category_label: ->
#     return CATEGORY_LABEL_MAP[@get('category')]

#   parse: (attrs) ->
#     return _.from_mongo(attrs)


# CardView = Backbone.View.extend
#   template: _.template($('#template-card').html())
#   # events:
#   #   'click .card-clip': 'on_click_toggle_clip'

#   initialize: ->
#     @binded = false;
#     @model.on 'change:is_clipped', @on_change_is_clipped, @
#     @model.on 'change:clip_count', @on_change_clip_count, @

#   render: (options) ->
#     options = _.extend({
#       no_detail_link: false
#       }, options || {})
#     ctxt = _.extend({_card: @.model.attributes, _view: @, options: options}, @.model)
#     @$el.html(@template(ctxt))
#     @set_clipped_status()
#     @set_read_status()

#     if @model.get('card_type') == 'bundle'
#       @$el.addClass('card-bundle')

#     if @model.attributes.category
#       @$el.addClass('card-' + @model.attributes.category)

#     if !@binded
#       @bind()

#     return this

#   bind: ->
#     if !@binded
#       @binded = true
#       @$el
#         .find('.card-clip').on('click', $.proxy(@on_click_toggle_clip, @)).end()
#         .find('.footer .comment').on('click', $.proxy(@on_click_comment, @)).end()

#   get_detail_url: ->
#     sc = @model.get('source_card')
#     if sc
#       return NCLIP_ROOT + "detail/#{sc._id}"
#     return NCLIP_ROOT + "detail/#{@model.id}"

#   set_clipped_status: ->
#     @$el.add_or_remove_class(@model.get('is_clipped'), 'card-clipped')

#   set_read_status: ->
#     @$el.add_or_remove_class(!@model.get('is_read'), 'card-unread')

#   on_click_toggle_clip: ->
#     @model.save('is_clipped', !@model.get('is_clipped'), {patch: true, wait: true})

#   on_click_comment: ->
#     console.log 'on_click_comment'
#     pipe.add
#       event: 'new-comment'
#       card_id: @model.id

#   on_change_is_clipped: ->
#     @set_clipped_status()

#   on_change_clip_count: ->
#     @$el.find('.clip-count').text(@model.get('clip_count'))


# CardList = Backbone.Collection.extend
#   model: Card

#   parse: (response) ->
#     return response.timeline

#   load_more: (options) ->
#     @fetch _.extend {
#       update: true
#       remove: false,
#       data:
#         skip: @length
#     }, options || {}


# watch_appearing = (el) ->
#   settings =
#     threshold: 0
#     container: window
#   get_visible = -> !$.belowthefold(el, settings)
#   current_visible = null
#   $(window).on 'scroll', ->
#     visible = get_visible()
#     if current_visible != visible
#       current_visible = visible
#       if visible
#         $(el).trigger('appear')
#       else
#         $(el).trigger('disappear')


# CardListView = Backbone.View.extend
#   template: _.template($('#template-card-list-item').html())
#   card_view_class: CardView

#   initialize: (options) ->
#     @collection.on('add', @addCard, @)
#     @collection.on('reset', @resetCardList, @)

#     @$tail_loader = $('<li class="loader"><span></span></li>').appendTo(options.el)

#     @$tail_loader.on 'click, appear', =>
#       @load_next()

#     watch_appearing(@$tail_loader.get()[0])

#   addCard: (card, collection, options) ->
#     idx = collection.indexOf(card)
#     show_author = if idx > 0 and collection.at(idx - 1).get('user_id') == card.get('user_id') then false else true
#     ctxt = _.extend({card: card, show_author: show_author, _card: card.attributes})
#     $new_node = $(@template(ctxt))

#     cardview = new @card_view_class({el: $new_node.find('.card:first'), model: card})
#     cardview.render()
#     $new_node.insertBefore(@$tail_loader)

#   resetCardList: (collection, options) ->
#     collection.forEach (card) =>
#       @addCard(card, collection)
#     if collection.length == 0
#       @$tail_loader.hide()

#   load_next: ->
#     @$tail_loader.addClass('loading')
#     @collection.load_more
#       success: (collection, resp, options) =>
#         if resp.timeline.length == 0
#           @$tail_loader.hide()
#       complete: (xhr, status) =>
#         @$tail_loader.removeClass('loading')


#   ###
#   clipped cardだけにしたり、しなかったり  
#   ###
#   toggle_filter_cliped_cards: (show) ->
#     $targets = @$el.find('.card:not(.card-clipped)')

#     # toggleOn = @$el.is('.hide_nonclipped_cards')

#     if show
#       $targets.slideDown();
#       @$el.removeClass('hide_nonclipped_cards');
#     else
#       $targets.slideUp();
#       @$el.addClass('hide_nonclipped_cards');


# CalendarCardView = CardView.extend()


# CalendarCardListView = CardListView.extend
#   template: _.template($('#template-calendar-card-list-item').html())
#   template_no_card: _.template($('#template-calendar-no-card').html())
#   card_view_class: CalendarCardView

#   resetCardList: (collection, options) ->
#     if collection.length == 0
#       $(@template_no_card()).insertBefore(@$tail_loader)
#     CardListView.prototype.resetCardList.apply(@, arguments)


# FocusCardList = CardList.extend
#   url: '/focus/timeline'


# CalendarCardList = CardList.extend
#   initialize: (options) ->
#     @date = options.date
#     @url = "/calendar/#{@date}/timeline"


# CardDetailView = Backbone.View.extend
#   template: _.template($('#template-card-detail').html())

#   initialize: ->
#     @subview = new CardView({model: @model})

#     @subcards = _.map(@model.get('subcards'), (x) -> new Card(x))
#     @subcard_views = _.map(@subcards, (x) -> new CardView({model: x}))

#   render: ->
#     ctxt = {$view: @, $model: @model, $m: $.proxy(@model.get, @model)}
#     @$el.html(@template(ctxt))
#     $details = @$el.find('#details')

#     @subview.setElement(@$el.find('#primary-card')).render({
#       no_detail_link: true
#     })

#     # subcardを追加
#     if @subcard_views.length
#       $subcards = $('<ul class="card-list card-list-subcards" />')
#       for view in @subcard_views
#         $node = $('<li class="subcard"><div class="card"></div></li>').appendTo($subcards)
#         view.setElement($node.find('.card')).render()
#       $subcards.insertAfter($details)

#     if $details.find('> li').length == 0
#       $details.remove()
#     return this


YTLRouter = Backbone.Router.extend
  routes:
    '': 'top'
    # 'detail/:card_id': 'detail'
    # 'calendar/:date': 'calendar'

  top: ->
    photolist = new TopPhotoList()
    $contents = $('#contents').html('')
    window.view = view = new PhotoListView(
      el: $('<ul id="top-photo-list" class="photo-list"></ul>').appendTo($contents)
      collection: photolist)
    photolist.fetch()

  detail: (card_id) ->
    $contents = $('#contents').html('')
    card = new Card({'_id': card_id})
    card.fetch
      success: (model, resp, options) ->
        view = new CardDetailView
          el: $('#contents')
          model: model
        view.render()

  calendar: (date) ->
    $contents = $('#contents').html('')
    cardlist = new CalendarCardList({date: date})

    window.view = view = new CalendarCardListView(
      el: $('<ul id="calendar-card-list" class="card-list"></ul>').appendTo($contents)
      collection: cardlist)

    cardlist.fetch()

#####
@router = new YTLRouter()
$ ->
  if !window.is_debug
    $('#debug').remove();
  Backbone.history.start({pushState: true})

  # $('body').on 'click', 'a[href^=#]', (e) ->
  #   e.preventDefault()
  #   window.router.navigate($(this).attr('href')[1..], {trigger: true})
