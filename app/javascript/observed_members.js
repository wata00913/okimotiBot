import { ObservedChannelMembers } from "./observed_channel_members"

const observedChannelMembers = new ObservedChannelMembers()

document.addEventListener("DOMContentLoaded", (_) => {
  const observedChannelsEl = document.getElementById("select_channel")

  if (observedChannelsEl !== null) {
    observedChannelsEl.addEventListener('change', onChangeObservedChannelsSelect)

    initChannelAndChannelMembers()
    
    const submitEl = document.querySelector('input[type="submit"]')
    submitEl.addEventListener('click', () => {
      onClickSubmitButton(observedChannelMembers)
    })
  }
})

async function onChangeObservedChannelsSelect(event) {
  const channelInfo = {
    id: event.target.value,
    name: event.target.options[event.target.selectedIndex].text
  }

  if (channelInfo.id === '') return
  if (document.getElementById(getObservedChannelElId(channelInfo)) !== null) return

  const data = await fetchChannelMembers(channelInfo.id)
  const channelMembersInfo = data.channel_members
  // 選択時、チャンネル内の全ユーザーは監視対象のチェックOFF
  channelMembersInfo.forEach((channelMemberInfo) => {
    channelMemberInfo.observe = false
  })

  insertChannelAndChannelMembers(channelInfo, channelMembersInfo)
  observedChannelMembers.registerChannel(channelInfo.id, channelMembersInfo, { destroy: true })
}

async function initChannelAndChannelMembers() {
  let data;
  data = await fetchObservedMembers()
  const observedMembersResponse = data.observed_members
  const promData = observedMembersResponse.map(async (channelToObservedMembers) => {
    const channel = channelToObservedMembers.channel
    const channelId = channel.id
    const observedMembers = channelToObservedMembers.members

    data = await fetchChannelMembers(channelId)
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
  const channelMembers = await Promise.all(promData)

  channelMembers.forEach(data => {
    insertChannelAndChannelMembers(data.channel, data.members)
    observedChannelMembers.registerChannel(data.channel.id, data.members, { destroy: false })
  })
}

function insertChannelAndChannelMembers(channelInfo, channelMembersInfo) {

  displayView(createChannelView(channelInfo), 'observed_channels', 'beforeend')

  channelMembersInfo.forEach(channelMemberInfo => {
    const view = createUserView(channelInfo, channelMemberInfo)
    displayView(view, getObservedChannelElId(channelInfo), 'beforeend')
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

// ES6でコンパイルした場合、onclickで関数を実行するとReferenceErrorが発生。
// 実行できるようにメソッドをwindowに設定
window.onClickObservedChannelButton = function onClickObservedChannelButton(parentEl, channelId)  {
  parentEl.remove()

  observedChannelMembers.deleteChannel(channelId)
}

function displayView(view, parentId, position) {
  const target = document.getElementById(parentId)
  target.insertAdjacentHTML(position, view)
}

function createChannelView(channelInfo) {
  const observedChannelElId = getObservedChannelElId(channelInfo)
  return escapeHTML`
    <div id="${observedChannelElId}" class="flex-col my-3">
      <div class="flex">
        <p>${channelInfo.name}</p>
        <button onclick="onClickObservedChannelButton(${observedChannelElId}, '${channelInfo.id}')" class="ml-5 px-4 py-1 bg-gray-500 text-white rounded-full hover:bg-blue-600 focus:outline-none focus:ring focus:ring-blue-300">削除</button>
      </div>
    </div>
    `
}

window.onClickObservedMemberCheckBox = function onClickObservedMemberCheckBox(event, channelId, accountId) {
  observedChannelMembers.setObserve(channelId, accountId, event.target.checked)
}

function onClickSubmitButton(observedChannelMembers) {
  const hiddenInputEl = document.getElementById('observed_members_attributes')
  hiddenInputEl.value = JSON.stringify(observedChannelMembers.getData())
}

function createUserView(channelInfo, userInfo) {
  const checkedStr = userInfo.observe ? 'checked' : ''
  return escapeHTML`
    <div id="${getObservedChannelMemberElId(channelInfo, userInfo)}" class="flex mb-1 px-4">
      <p class="flex items-center">${userInfo.name}</p>
      <img src="${userInfo.image_url}" alt="アカウントアイコン" class="ml-4 w-[50px] h-[50px]">
      <label for="${userInfo.channel_member_id}" class="flex items-center ml-4">
        <input type="checkbox" onclick="onClickObservedMemberCheckBox(event, '${channelInfo.id}', ${userInfo.channel_member_id})" id="${userInfo.channel_member_id}" ${checkedStr} />
        監視対象
      </label>
    </div>
    `
}

function getObservedChannelElId(channelInfo) {
  return `observed_channel_${channelInfo.id}`
}

function getObservedChannelMemberElId(channelInfo, userInfo) {
  return `observed_channel_member_${channelInfo.id}_${userInfo.channel_member_id}`
}

function escapeHTML(strings, ...values) {
  return strings.reduce((result, str, i) => {
    const value = values[i - 1];
    if (typeof value === "string") {
      return result + escapeSpecialChars(value) + str;
    } else {
      return result + String(value) + str;
    }
  });
}

function escapeSpecialChars(str) {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}


