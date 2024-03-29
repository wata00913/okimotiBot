import { ObservedChannelMembers } from "./observed_channel_members"
import { displayView, escapeHTML } from "./view_helper"

// 監視対象チャンネルと監視対象ユーザーの管理
let observedChannelMembers

/**
 * 画面ロード時の処理
 */
document.addEventListener("turbo:load", (_) => {
  const observedChannelsEl = document.getElementById("observed_channels")

  if (observedChannelsEl !== null) {
    observedChannelMembers = new ObservedChannelMembers()

    initChannelAndChannelMembers()
    
    const submitEl = document.querySelector('input[type="submit"]')
    submitEl.addEventListener('click', () => {
      onClickSubmitButton(observedChannelMembers)
    })
  }
})

/**
 * 監視対象チャンネルと監視対象ユーザーが存在する場合、
 * 画面にそれらを初期表示する
 */
async function initChannelAndChannelMembers() {
  let data
  try {
    data = await fetchObservedMembers()
  } catch (error) {
    console.log(error)
    return
  }

  const observedMembersResponse = data.observed_members
  const promData = observedMembersResponse.map(async (channelToObservedMembers) => {
    const channel = channelToObservedMembers.channel
    const channelId = channel.id
    const observedMembers = channelToObservedMembers.members

    let data
    try {
      data = await fetchChannelMembers(channelId)
    } catch (error) {
      console.log(error)
      return null
    }

    const members = data.channel_members

    members.forEach((member) => {
      const observedMember = observedMembers.find(m => m.channel_member_id === member.channel_member_id)
      if(observedMember === undefined) {
        member.observe = false
      } else {
        member.observe = true
        member.id = observedMember.id
      }
    })
    return { channel: channel, members: members }
  })
  let channelMembers = await Promise.all(promData)
  channelMembers = channelMembers.filter(d => d !== null)

  channelMembers.forEach(data => {
    insertChannelAndChannelMembers(data.channel, data.members)
    observedChannelMembers.registerChannel(data.channel.id, data.members, { destroy: false })
  })
}


/**
 * イベントハンドラー
 */
window.onClickChannelsReloadButton = async function onClickChannelsReloadButton() {
  const checkboxesEl = document.querySelectorAll("#channels input[type=checkbox]")
  const oldChannelIds = []
  checkboxesEl.forEach(checkboxEl => oldChannelIds.push(checkboxEl.value))

  const response = await fetchChannels()
  const channels = response.channels
  const updatedAt = response.updated_at
  const currentChannelIds = channels.map(c => c.channel_id)

  const channelsReloadUpdatedAtEl = document.getElementById('channel-reload-updated-at')
  channelsReloadUpdatedAtEl.textContent = updatedAt

  channels.forEach((channel) => {
    const checkBoxEl = document.getElementById(`select-channel-${channel.channel_id}`)
    if (checkBoxEl === null) {
      displayView(createChannelCheckBoxView(channel, false), 'channels', 'beforeend')
    } else {
      const labelEl = checkBoxEl.previousElementSibling
      console.log(labelEl)
      labelEl.textContent = `#${channel.name}`

      checkBoxEl.id = getSelectChannelCheckBoxElId(channel)
      checkBoxEl.name = getSelectChannelCheckBoxElId(channel)
      checkBoxEl.value = channel.name
    }
  })

  const willDeletedChannelIds = new Set(oldChannelIds)
  currentChannelIds.forEach(currentId => willDeletedChannelIds.delete(currentId))
  willDeletedChannelIds.forEach((channelId) => {
    const checkBoxEl = document.getElementById(`select-channel-${channelId}`)
    if (checkBoxEl.checked) {
      // チェックボックスをオフにして監視対象ユーザーの選択領域を削除する
      checkBoxEl.checked = false
      const event = new Event('change')
      checkBoxEl.dispatchEvent(event)

      observedChannelMembers.deleteChannel(channelId)
    }
    checkBoxEl.parentElement.remove()
  })
}

window.onChangeObservedChannelsCheckBox = async function onChangeObservedChannelsCheckBox(event, channelId, name) {
  const channelInfo = {
    id: channelId,
    name: name
  }
  if (channelInfo.id === '') return

  const observedChannelEl = document.getElementById(getObservedChannelElId(channelInfo))

  if (!event.target.checked) {
    if (observedChannelEl === null) return

    observedChannelEl.remove()
    observedChannelMembers.deleteChannel(channelInfo.id)
    return
  }

  if (observedChannelEl !== null) return

  try {
    const data = await fetchChannelMembers(channelInfo.id)

    const channelMembersInfo = data.channel_members
    // 選択時、チャンネル内の全ユーザーは監視対象のチェックOFF
    channelMembersInfo.forEach((channelMemberInfo) => {
      channelMemberInfo.observe = false
    })

    insertChannelAndChannelMembers(channelInfo, channelMembersInfo)
    observedChannelMembers.registerChannel(channelInfo.id, channelMembersInfo, { destroy: true })
  } catch (error) {
    console.error(error)
    displayView(createNoticeOrAlertMessageView('Slackチャンネル内のメンバー取得に失敗しました', true), 'notice-or-alert-message', 'beforeend')
  }
}

window.onClickObservedMemberCheckBox = function onClickObservedMemberCheckBox(event, channelId, accountId) {
  observedChannelMembers.setObserve(channelId, accountId, event.target.checked)
}

function onClickSubmitButton(observedChannelMembers) {
  const hiddenInputEl = document.getElementById('observed_members')
  hiddenInputEl.value = JSON.stringify(observedChannelMembers.getData())
}


function insertChannelAndChannelMembers(channelInfo, channelMembersInfo) {

  displayView(createChannelView(channelInfo), 'observed_channels', 'beforeend')

  channelMembersInfo.forEach(channelMemberInfo => {
    const view = createUserView(channelInfo, channelMemberInfo)
    displayView(view, getObservedChannelElId(channelInfo), 'beforeend')
  })
}


/*
 * Viewの作成
 */
function createNoticeOrAlertMessageView(message, isError) {
  let colorClass = ""
  if (isError) {
    colorClass = "bg-red-100 border-red-400 text-red-700"
  } else {
    colorClass = "bg-green-100 border-green-400 text-green-700"
  }
  return escapeHTML`
    <div class="border ${colorClass} px-4 py-3 rounded relative" role="alert">
      <span class="block sm:inline">${message}</span>
    </div>
    `
}

function createChannelCheckBoxView(channelInfo, isChecked) {
  const checkedStr = isChecked ? 'checked="checked"' : ''
  return escapeHTML`
    <div>
      <label class="mr-2 block font-medium text-sm text-gray-700" for="select_channel">#${channelInfo.name}</label>
      <input type="checkbox" 
        name="select-channel-${channelInfo.channel_id}"
        id="select-channel-${channelInfo.channel_id}"
        value="${channelInfo.name}" onclick="onChangeObservedChannelsCheckBox(event, '${channelInfo.channel_id}', '${channelInfo.name}')"
        ${checkedStr}
      >
    </div>
    `
}

function createChannelView(channelInfo) {
  const observedChannelElId = getObservedChannelElId(channelInfo)
  return escapeHTML`
    <div id="${observedChannelElId}" class="flex-col my-3">
      <div class="flex">
        <p>#${channelInfo.name}</p>
      </div>
    </div>
    `
}


function createUserView(channelInfo, userInfo) {
  const checkedStr = userInfo.observe ? 'checked' : ''
  return escapeHTML`
    <div id="${getObservedChannelMemberElId(channelInfo, userInfo)}" class="flex mb-1 px-4">
      <p class="flex items-center">${userInfo.name}</p>
      <img src="${userInfo.image_url}" alt="アカウントアイコン" class="ml-4 w-[50px] h-[50px]">
      <p class="flex items-center ml-6">監視対象</p>
      <label for="${userInfo.channel_member_id}" class="flex items-center ml-4">
        <input type="checkbox" 
          onclick="onClickObservedMemberCheckBox(event, '${channelInfo.id}', ${userInfo.channel_member_id})" id="${userInfo.channel_member_id}" ${checkedStr}
          class="peer sr-only"
        />
        <span
          class="block w-[2em] cursor-pointer bg-gray-500 rounded-full 
          p-[1px] after:block after:h-[1em] after:w-[1em] after:rounded-full 
          after:bg-white after:transition peer-checked:bg-blue-500 
          peer-checked:after:translate-x-[calc(100%-2px)]"
        >
      </label>
    </div>
    `
}

/**
 * idの取得関数
 */
function getObservedChannelElId(channelInfo) {
  return `observed_channel_${channelInfo.id}`
}

function getObservedChannelMemberElId(channelInfo, userInfo) {
  return `observed_channel_member_${channelInfo.id}_${userInfo.channel_member_id}`
}

function getSelectChannelCheckBoxElId(channelInfo) {
  return `select-channel-${channelInfo.channel_id}`
}

/*
 * API通信
 */
function fetchChannels() {
  return fetch(`/api/slack_channels`)
    .then((response) => {
      if (!response.ok) {
        return Promise.reject(new Error(`${response.status}: ${response.statusText}`));
      } else {
        return response.json()
      }
    })
}

function fetchObservedMembers() {
  return fetch(`/api/observed_members`)
    .then((response) => {
      if (!response.ok) {
        return Promise.reject(new Error(`${response.status}: ${response.statusText}`));
      } else {
        return response.json()
      }
    })
}

function fetchChannelMembers(channelId) {
  return fetch(`/api/slack_channels/${channelId}/members`)
    .then((response) => {
      if (!response.ok) {
        return Promise.reject(new Error(`${response.status}: ${response.statusText}`));
      } else {
        return response.json()
      }
    })
}
