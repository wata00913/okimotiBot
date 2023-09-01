import { ObservedChannelMembers } from "./observed_channel_members"

const observedChannelMembers = new ObservedChannelMembers()

document.addEventListener("DOMContentLoaded", (_) => {
  const observedChannelsEl = document.getElementById("select_channel")

  if (observedChannelsEl !== null) {
    observedChannelsEl.addEventListener('change', insertChannelAndChannelMembers)
  }
})


async function insertChannelAndChannelMembers(event) {
  const channelInfo = {
    id: event.target.value,
    name: event.target.options[event.target.selectedIndex].text
  }

  if (channelInfo.id === '') return
  if (document.getElementById(getObservedChannelElId(channelInfo)) !== null) return

  displayView(createChannelView(channelInfo), 'observed_channels', 'beforeend')

  const data = await fetchChannelMembers(channelInfo.id)
  const channelMembers = data.channel_members
  channelMembers.forEach(channelMember => {
    const view = createUserView(channelInfo, channelMember)
    displayView(view, getObservedChannelElId(channelInfo), 'beforeend')
  })

  observedChannelMembers.registerChannel(channelInfo.id,
    channelMembers.map(m => m.account_id)
  )

}

function fetchChannelMembers(channelId) {
  return fetch(`/api/observed_members?channel_id=${channelId}`)
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

function createUserView(channelInfo, userInfo) {
  return escapeHTML`
    <div id="${getObservedChannelMemberElId(channelInfo, userInfo)}" class="flex mb-1 px-4">
      <p class="flex items-center">${userInfo.name}</p>
      <img src="${userInfo.image_url}" alt="アカウントアイコン" class="ml-4 w-[50px] h-[50px]">
      <label for="${userInfo.account_id}" class="flex items-center ml-4">
        <input type="checkbox" onclick="onClickObservedMemberCheckBox(event, '${channelInfo.id}', '${userInfo.account_id}')" id="${userInfo.account_id}" />
        監視対象
      </label>
    </div>
    `
}

function getObservedChannelElId(channelInfo) {
  return `observed_channel_${channelInfo.id}`
}

function getObservedChannelMemberElId(channelInfo, userInfo) {
  return `observed_channel_member_${channelInfo.id}_${userInfo.account_id}`
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


